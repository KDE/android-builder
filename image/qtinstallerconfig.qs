/*  
   Copyright 2015  Andreas Cord-Landwehr <cordlandwehr@kde.org>

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

   1. Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

   THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
   IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
   OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
   IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
   INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
   NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
   THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

function Controller()
{
    console.log("Control script loaded: Qt 5.5 Android with Linux 64 bit host.")
    installer.autoRejectMessageBoxes
}

Controller.prototype.WelcomePageCallback = function()
{
    gui.clickButton(buttons.NextButton)
}

Controller.prototype.LicenseAgreementPageCallback = function()
{
    var page = gui.pageWidgetByObjectName("LicenseAgreementPage")
    page.AcceptLicenseRadioButton.setChecked(true)
}

// skip qt account creation
Controller.prototype.CredentialsPageCallback = function()
{
    var page = gui.pageWidgetByObjectName("CredentialsPage")
    page.EmailLineEdit.setText("[no-mail]")
    page.PasswordLineEdit.setText("[your_password_here]")
    page.ServiceTermsCheckBox.setChecked(true)
    // installer logic expects clicked signal to be set
    // to enable switch to next page
    page.ServiceTermsCheckBox.clicked()
    gui.clickButton(buttons.NextButton)
}

Controller.prototype.IntroductionPageCallback = function()
{
    gui.clickButton(buttons.NextButton)
}

Controller.prototype.TargetDirectoryPageCallback = function()
{
    var page = gui.pageWidgetByObjectName("TargetDirectoryPage")
    // set target directory
    page.TargetDirectoryLineEdit.text = "/opt/android/Qt5.5.0"
    gui.clickButton(buttons.NextButton)
}

// accept license agreement
Controller.prototype.LicenseAgreementPageCallback = function()
{
    var pageAgreement = gui.pageWidgetByObjectName("LicenseAgreementPage")
    pageAgreement.AcceptLicenseRadioButton.setChecked(true)
    gui.clickButton(buttons.NextButton)
}

// select components
Controller.prototype.ComponentSelectionPageCallback = function()
{
    var page = gui.pageWidgetByObjectName("ComponentSelectionPage")
    page.deselectAll()
    page.selectComponent("qt.55.android_armv7")
    page.selectComponent("qt.55.qtquickcontrols")
    page.selectComponent("qt.55.qtscript")
    page.selectComponent("qt.55.qtlocation")
    page.selectComponent("qt.55.qt3d")

    gui.clickButton(buttons.NextButton)
}

// confirm selected components
Controller.prototype.ReadyForInstallationPageCallback = function()
{
    gui.clickButton(buttons.CommitButton)
}

Controller.prototype.PerformInstallationPageCallback = function()
{
    // IMPORTANT: if you ever run this script with "--verbose",
    // then you will encounter the "funny" behavior that the
    // commit-button is not activated correctly after the installation
    // finished.
    // A possible workaround is to uncomment the following line, which
    // calls the next-button with a 60-second timeout. This means, after
    // the button gets enabled in the UI.
    //    console.log("Timeout for installation: 60 sec, next-button is activated afterward.")
    //    gui.clickButton(buttons.NextButton, 60000)
    gui.clickButton(buttons.CommitButton)
}

Controller.prototype.FinishedPageCallback = function()
{
    console.log("Installation finished.")
    var page = gui.pageWidgetByObjectName("FinishedPage")
    console.log(page.LaunchQtCreatorCheckBoxForm.launchQtCreatorCheckBox.setChecked(false));
    gui.clickButton(buttons.FinishButton)
}

