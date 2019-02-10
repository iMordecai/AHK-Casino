#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Persistent
#SingleInstance, Force

LVWidth:= 280							; default ListView width for betting results
BtnWidth := (LVWidth-28)/3				; width fof buttons (buttons will be about the same as ListView)
TotalCoins := "Please update your"		; placeholder for coins amount
Cooldown := 0

Gui, Casino:New
Gui, Casino:Add, ListView, w%LVWidth% h200, Bet|Multiplier|Won|SubTotal
Gui, Casino:Add, Edit, section w%BtnWidth% gNewBet vPercentage Number,		; edit box for %
Gui, Casino:Add, UpDown, Range0.01-100 gNewBet, 20							; UpDown (default = 20)
Gui, Casino:Add, Text, ys+3 xp+%BtnWidth%+5, `%
Gui, Casino:Add, Edit, ys w%BtnWidth%  vBet Number, 						; amount to bet
Gui, Casino:Add, Button, ys-1 wp gBet, Bet									; copies ".bet " and coins amount to bet
Gui, Casino:Font, s13
Gui, Casino:Add, Text, w%LVWidth% vTotal Center xs, %TotalCoins% coins
Gui, Casino:Font
Gui, Casino:Add, Progress, wp h4 vProgress Range0-120, 0					; small cooldown progress bar (60 minutes)
Gui, Casino:Add, Edit, section xs w%LVWidth% vResult hwndHED1 Center,		; paste the betting result here
SetEditCueBanner(HED1, "Update coins amount here")							; adds a placeholder/cue to the text box
Gui, Casino:Add, Button, xs-1 wp+2 gUpdate Default, Update
Gui, Casino:Show, , AHK Casino

Return

NewBet:		; when the % is updates, this is run
	Gui, Casino:Submit, NoHide											; get the data on the GUI
	GuiControl, Text, Bet, % Format("{1:i}",TotalCoins*Percentage/100)	; updates the "Bet" edit box with TotalCoins * %
Return

Bet:		; when pressing the "Bet" button
	Gui, Casino:Submit, NoHide
	Clipboard := ".bet " Bet											; copies to clipboard ". bet " and betting amount
Return

Update:
	Gui, Casino:Submit, NoHide
	FoundLoss 			:= RegExMatch(Result, "Sorry, you lost ([\d,]*) coins", zloss)							; checks if there was a loss
	FoundWin 			:= RegExMatch(Result, "You hit a ([\d\.]*)x multiplier and won ([\d,]*) coins", zwin)	; checks if there was a win
	FoundWinPercentage 	:= RegExMatch(Result, "You hit a ([\d\.]*)x multiplier on your ([\d,]*) coin bet and won ([\d,]*) coins", zwinp)	; checks if the
	FoundAmount			:= RegExMatch(Result, "^\W*([\d,]*)\W*(?:coins)?", zamount)								; checks if just a number (or number and " coins")
	If (FoundLoss > 0)
	{
		TotalCoins -= StrReplace(zloss1, ",")															; subtracts the loss (removing the commas from the number)
		GuiControl, Text, Total, % RegExReplace(TotalCoins, "(?:^[^1-9.]*[1-9]\d{0,2}|(?<=.)\G\d{3})(?=(?:\d{3})+(?:\D|$))", "$0,") " coins" ; show total coins with commas
		GuiControl, Text, Result,																		; removes the betting results (that was pasted)
		LV_Add("", zloss1, "0", zloss1, TotalCoins)														; adds the result to the ListView
		LV_ModifyCol()																					; resizes the ListView to fit the width
		LV_Modify(LV_GetCount(), "Vis")																	; scrolls to the last row
		GuiControl, Text, Bet, % Format("{1:i}",TotalCoins*Percentage/100)								; updaes the Bed edit field with new percentage
	} 
	Else If (FoundWin > 0)
	{
		TotalCoins += StrReplace(zwin2, ",")															; adds the new winnings to the TotalCoins
		GuiControl, Text, Total, % RegExReplace(TotalCoins, "(?:^[^1-9.]*[1-9]\d{0,2}|(?<=.)\G\d{3})(?=(?:\d{3})+(?:\D|$))", "$0,") " coins" ; show total coins with commas
		GuiControl, Text, Result,
		LV_Add("", Bet, zwin1, zwin2, TotalCoins)
		LV_ModifyCol()
		LV_Modify(LV_GetCount(), "Vis")
		GuiControl, Text, Bet, % Format("{1:i}",TotalCoins*Percentage/100)
	} 
	Else If (FoundWinPercentage > 0)
	{
		TotalCoins += StrReplace(zwinp3, ",")															; adds the new winnings to the TotalCoins
		GuiControl, Text, Total, % RegExReplace(TotalCoins, "(?:^[^1-9.]*[1-9]\d{0,2}|(?<=.)\G\d{3})(?=(?:\d{3})+(?:\D|$))", "$0,") " coins" ; show total coins with commas
		GuiControl, Text, Result,
		LV_Add("", zwinp2, zwinp1, zwinp3, TotalCoins)
		LV_ModifyCol()
		LV_Modify(LV_GetCount(), "Vis")
		GuiControl, Text, Bet, % Format("{1:i}",TotalCoins*Percentage/100)
	}
	Else If (FoundAmount > 0) AND (StrLen(zamount1) > 0)
	{
		TotalCoins := StrReplace(zamount1, ",")															; updates the new TotalCoins
		GuiControl, Text, Total, % RegExReplace(TotalCoins, "(?:^[^1-9.]*[1-9]\d{0,2}|(?<=.)\G\d{3})(?=(?:\d{3})+(?:\D|$))", "$0,") " coins" ; show total coins with commas
		GuiControl, Text, Bet, % Format("{1:i}",TotalCoins*Percentage/100)
		GuiControl, Text, Result,
		SetEditCueBanner(HED1, "Paste the result here")													; changes the placeholder/cue of the update edit box
	}
	GuiControl, , Progress, 0																			; resets the progress bar to 0
	GuiControl, Casino: +cBlue, Progress																; changes the progress bar color
	Cooldown := 0																						; resets the cooldown amount to 0
	SetTimer, UpdateCooldown, 30000																		; sets a timer to update the cooldown proress every 30 seconds
Return

UpdateCooldown:
	Cooldown++									; adds 1 to cooldown
	GuiControl, Casino:, Progress, +1			; adds to the progress bar
	if (Cooldown > 119)
	{
		GuiControl, Casino: +cGreen, Progress	; (if Cooldown is 120) change the progress bar color
		SetTimer, UpdateCooldown, Off			; cancel the timer
	}
Return

; function to add a placeholder/cue to an editbox
SetEditCueBanner(HWND, Cue) {
   Static EM_SETCUEBANNER := (0x1500 + 1)
   Return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue)
}

Return