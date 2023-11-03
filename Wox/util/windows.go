package util

import (
	"fmt"
	"github.com/disintegration/imaging"
	"github.com/fcjr/geticon"
	"github.com/go-vgo/robotgo"
	"image"
	"wox/util/keybd_event"
)

func GetWindowShowLocation(windowWidth int) (x, y int) {
	var curDisplayX, curDisplayW, curDisplayH int

	curX, curY := robotgo.Location()
	for i := 0; i < robotgo.DisplaysNum(); i++ {
		displayX, displayY, displayW, displayH := robotgo.GetDisplayBounds(i)
		if curX >= displayX && curX <= displayX+displayW && curY >= displayY && curY <= displayY+displayH {
			curDisplayX, curDisplayW, curDisplayH = displayX, displayW, displayH
		}
	}

	x = curDisplayX + (curDisplayW-windowWidth)/2
	y = curDisplayH / 5

	return
}

func GetActiveWindowIcon() (image.Image, error) {
	activePid := robotgo.GetPid()
	icon, err := geticon.FromPid(uint32(activePid))
	if err != nil {
		return nil, err
	}

	thumbnail := imaging.Thumbnail(icon, 60, 60, imaging.Lanczos)
	return thumbnail, nil
}

func GetActiveWindowHash() string {
	activePid := robotgo.GetPid()
	activeTitle := robotgo.GetTitle()
	return Md5([]byte(fmt.Sprintf("%s%d", activeTitle, activePid)))
}

func SimulateCtrlC() error {
	kb, err := keybd_event.NewKeyBonding()
	if err != nil {
		return err
	}

	kb.SetKeys(keybd_event.VK_C)
	if IsWindows() || IsLinux() {
		kb.HasCTRL(true)
	}
	if IsMacOS() {
		kb.HasSuper(true)
	}
	err = kb.Launching()
	if err != nil {
		return err
	}

	return nil
}

func SimulateCtrlV() error {
	kb, err := keybd_event.NewKeyBonding()
	if err != nil {
		return err
	}

	kb.SetKeys(keybd_event.VK_V)
	if IsWindows() || IsLinux() {
		kb.HasCTRL(true)
	}
	if IsMacOS() {
		kb.HasSuper(true)
	}
	err = kb.Launching()
	if err != nil {
		return err
	}

	return nil
}