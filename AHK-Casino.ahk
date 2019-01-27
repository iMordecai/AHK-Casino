﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Persistent
#SingleInstance, Force

LVWidth:= 200
BtnWidth := (LVWidth-29)/3
TotalCoins := "Please update your"
Cooldown := 0

Gui, Casino:New
Gui, Casino:Add, ListView, w%LVWidth% h200, Bet|Multiplier|Won|SubTotal
Gui, Casino:Add, Edit, section w%BtnWidth%  vPercentage Number,
Gui, Casino:Add, UpDown, Range0.01-100 gNewBet, 20
Gui, Casino:Add, Edit, ys wp  vBet Number,1
Gui, Casino:Add, Button, ys-1 wp gGo, Go
Gui, Casino:Font, s13
Gui, Casino:Add, Text, w%LVWidth% vTotal Center xs, %TotalCoins% coins
Gui, Casino:Font
Gui, Casino:Add, Progress, wp h4 vProgress Range0-60, 0
Gui, Casino:Add, Edit, section xs w%LVWidth% vResult,
Gui, Casino:Add, Button, xs-1 wp+2 gUpdate, Update
Gui, Casino:Show, , AHK Casino

Return

NewBet:
Gui, Casino:Submit, NoHide
GuiControl, Text, Bet, % Format("{1:i}",TotalCoins*Percentage/100)
Return

Go:
Gui, Casino:Submit, NoHide
Clipboard := ".bet " Bet
Return

Update:
Gui, Casino:Submit, NoHide
FoundLoss 	:= RegExMatch(Result, "Sorry, you lost ([\d,]*) coins", zloss)
FoundWin 	:= RegExMatch(Result, "You hit a ([\d\.]*)x multiplier and won ([\d,]*) coins", zwin)
FoundAmount	:= RegExMatch(Result, "^\W*([\d,]*)\W*(?:coins)?", zamount)
If (FoundLoss > 0)
{
	TotalCoins -= StrReplace(zloss1, ",")
	GuiControl, Text, Total, % TotalCoins " coins"
	GuiControl, Text, Result,
	Lv_Add("", zloss1, "0", zloss1, TotalCoins)
	LV_ModifyCol()
	GuiControl, Text, Bet, % Format("{1:i}",TotalCoins*Percentage/100)
} 
Else If (FoundWin > 0)
{
	TotalCoins += StrReplace(zwin2, ",")
	GuiControl, Text, Total, % TotalCoins " coins"
	GuiControl, Text, Result,
	Lv_Add("", Bet, zwin1, zwin2, TotalCoins)
	LV_ModifyCol()
	GuiControl, Text, Bet, % Format("{1:i}",TotalCoins*Percentage/100)
}
Else If (FoundAmount > 0) AND (StrLen(zamount1) > 0)
{
	TotalCoins := StrReplace(zamount1, ",")
	GuiControl, Text, Total, % TotalCoins " coins"
	GuiControl, Text, Bet, % Format("{1:i}",TotalCoins*Percentage/100)
	GuiControl, Text, Result,
}
GuiControl, , Progress, 0
Cooldown := 0
SetTimer, UpdateCooldown, 30000
Return

UpdateCooldown:
Cooldown++
GuiControl, Casino:, Progress, +1
Return