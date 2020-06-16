package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"
)

const (
	readsize = 64 << 10
)

type pipeConn struct {
	ctrlPipeName  string
	eventPipeName string
	events        chan string
}

func newPipeConn(ctrlPipeName string, eventPipeName string) *pipeConn {
	pc := &pipeConn{
		ctrlPipeName:  ctrlPipeName,
		eventPipeName: eventPipeName,
		events:        make(chan string),
	}

	// create "control" pipe
	os.Remove(pc.ctrlPipeName)
	err := syscall.Mkfifo(pc.ctrlPipeName, 0660)
	if err != nil && !os.IsExist(err) {
		log.Fatal("Mkfifo error:", err)
	}

	// create "event" pipe
	os.Remove(pc.eventPipeName)
	err = syscall.Mkfifo(pc.eventPipeName, 0660)
	if err != nil && !os.IsExist(err) {
		log.Fatal("Mkfifo error:", err)
	}

	// start events pump
	go pc.startEventPump()

	return pc
}

func (pc *pipeConn) read() string {
	var bytesRead int
	var err error
	buf := make([]byte, readsize)
	for {
		input, err := openFifo(pc.ctrlPipeName, os.O_RDONLY)
		if err != nil {
			break
		}
		for err == nil {
			bytesRead, err = input.Read(buf)
			//atomic.AddInt64(&byteCount, int64(delta))

			if err == io.EOF {
				break
			}

			fmt.Printf("read: %d\n", bytesRead)

			fmt.Print(string(buf))
		}
		fmt.Println("closing reader")
		input.Close()
		fmt.Println("closed reader")
		return ""
	}
	log.Fatal(err)
	return ""
}

func (pc *pipeConn) write(s string) {
	output, err := openFifo(pc.ctrlPipeName, os.O_WRONLY)
	if err != nil {
		log.Fatal(err)
	}
	defer output.Close()
	output.Write([]byte(s))
	time.Sleep(time.Second)
	output.WriteString("str 1\n")
	time.Sleep(time.Second)
	output.WriteString("str 2\n")
	time.Sleep(time.Second)
	output.WriteString("quit\n")
}

func (pc *pipeConn) emitEvent(evt string) {
	//fmt.Printf("Emit event: %s\n", evt)
	select {
	case pc.events <- evt:
		//fmt.Println("Event sent to queue")
	default:
		//fmt.Println("No event listeners")
	}
}

func (pc *pipeConn) startEventPump() {

	for {
		output, err := openFifo(pc.eventPipeName, os.O_WRONLY)
		if err != nil {
			log.Fatal(err)
		}

		select {
		case evt := <-pc.events:
			//fmt.Printf("Write event: %s\n", evt)
			output.WriteString(evt + "\n")
		}

		output.Close()
	}
}

func openFifo(path string, oflag int) (f *os.File, err error) {

	//fmt.Printf("before opening: %d\n", oflag)

	f, err = os.OpenFile(path, oflag, os.ModeNamedPipe)
	if err != nil {
		return
	}

	//fmt.Println("opened")

	// // In case we're using a pre-made file, check that it's actually a FIFO
	// fi, err := f.Stat()
	// if err != nil {
	// 	f.Close()
	// 	return nil, err
	// }
	// if fi.Mode()&os.ModeType != os.ModeNamedPipe {
	// 	f.Close()
	// 	return nil, os.ErrExist
	// }
	return
}

func main() {

	// Setup our Ctrl+C handler
	setupCloseHandler()

	pipe := newPipeConn("test.ui", "test.events")

	go func() {

		i := 0
		for {
			pipe.emitEvent(fmt.Sprintf("click btn%d", i))
			time.Sleep(10 * time.Millisecond)
			i++
		}

	}()

	_ = pipe.read()

	//time.Sleep(5 * time.Second)

	pipe.write("hello!!!")

	//time.Sleep(5 * time.Second)

	_ = pipe.read()

	fmt.Println("we done!")

	return

	/*

		bash -c 'echo "1"; sleep 2; echo "2"; sleep 2; echo "3"; sleep 2; echo "4"; sleep 2; echo "5";' > test.ui

		bash -c 'echo "1"; sleep 3; echo "2"; sleep 3; echo "3"; sleep 3; echo "4"; sleep 3; echo "5";' | sed -e 's/^/prefix1 /' > test.ui

		ls -al /usr/bin | sed -e 's/^/prefix1 /' > test.ui
	*/

	// wait for CTRL+C
	// fmt.Println("CTRL+C to exit...")
	// for {
	// 	time.Sleep(10 * time.Second)
	// }
}

func setupCloseHandler() {
	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-c
		fmt.Println("\r- Ctrl+C pressed in Terminal")
		os.Exit(0)
	}()
}
