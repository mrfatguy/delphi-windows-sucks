unit frmMain;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  Graphics, dExif, dIPTC, ComCtrls, Grids, dFolderDialog, INIFiles, DateUtils,
  Variants;

type
  TMainForm = class(TForm)
    pnlProcess: TPanel;
    pbMain: TProgressBar;
    btnAbort: TButton;
    Label1: TLabel;
    pnlMain: TPanel;
    Label2: TLabel;
    lblTimeZone: TLabel;
    gbFile: TGroupBox;
    lblDir: TLabel;
    btnSelectDir: TButton;
    sgSummary: TStringGrid;
    btnGo: TButton;
    btnCancel: TButton;
    cbTimeZone: TComboBox;
    btnAbout: TButton;

    procedure FormCreate(Sender: TObject);
    procedure btnSelectDirClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure cbTimeZoneChange(Sender: TObject);
    procedure sgSummaryDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure FormShow(Sender: TObject);
    procedure sgSummarySelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure btnAboutClick(Sender: TObject);
    procedure btnGoClick(Sender: TObject);
    procedure btnAbortClick(Sender: TObject);

    procedure PrepareHeaders();
    procedure ParseDir(DirName: String);
    procedure ChangeState(Enable: Boolean);
    procedure CenterControl(ParentObject, CenterObject: TControl; bTop, bLeft: Boolean; Space: Integer);

    function GetFileDate(TheFileName: String): String;
    function SetFileDate(FileName: string; Value: TDateTime): String;
    function ConvertDateTime(DateTime: String): String;
    function CountFiles(Directory, Extension: String): Integer;
    function IfThen(AValue: Boolean; const ATrue: Integer; const AFalse: Integer): Integer;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  ImgData: TImgData;
  SelectionMatrix: array of array[0..4] of Integer;
  Timezones: TStringList;
  Abort: Boolean;

const
  FileExtension: String = '*.jp*g';

implementation

uses frmInfo;

{$R *.DFM}

procedure TMainForm.FormCreate(Sender: TObject);
var
  ini: TINIFile;
  sTimeZone, sDir: String;
  tsTemp: TStringList;
  a: Integer;
begin
  ImgData := TImgData.Create;
  Timezones := TStringList.Create();

  ini := TINIFile.Create(ExtractFilePath(Application.ExeName) + 'WindowsSucks.ini');
  sDir := ini.ReadString('Main', 'LastDir', ExtractFilePath(Application.ExeName));

  if DirectoryExists(sDir) then
    lblDir.Caption := sDir
  else
    lblDir.Caption := ExtractFilePath(Application.ExeName);

  MainForm.Top := ini.ReadInteger('Main', 'Top', 120);
  MainForm.Left := ini.ReadInteger('Main', 'Left', 300);
  MainForm.Width := ini.ReadInteger('Main', 'Width', 801);
  MainForm.Height := ini.ReadInteger('Main', 'Height', 519);

  if FileExists(ExtractFilePath(Application.ExeName) + 'WindowsSucks.tzf') then
  begin
    tsTemp := TStringList.Create();
    tsTemp.LoadFromFile(ExtractFilePath(Application.ExeName) + 'WindowsSucks.tzf');

    for a := 0 to tsTemp.Count - 1 do
    begin
      cbTimeZone.Items.Add(Copy(tsTemp[a], 1, Pos('#', tsTemp[a]) - 1));

      sTimeZone := Copy(tsTemp[a], Pos('#', tsTemp[a]) + 1, Length(tsTemp[a]));
      sTimezone := StringReplace(sTimeZone, '.', DecimalSeparator, []);
      TimeZones.Add(sTimezone);
    end;


    tsTemp.Free();
  end
  else
  begin
    cbTimeZone.Enabled := False;
    lblTimeZone.Enabled := False;
    lblTimeZone.Caption := 'File "WindowsSucks.tzf" not found or invalid!';
  end;

  cbTimeZone.ItemIndex := ini.ReadInteger('Main', 'LastTZ', Timezones.IndexOf('0'));
  ini.Free();
end;

function TMainForm.CountFiles(Directory, Extension: String): Integer;
var
	Rec : TSearchRec;
	nFileCount : integer;
begin
	nFileCount := 0;
	if FindFirst(IncludeTrailingBackslash(Directory) + Extension, faAnyFile, Rec) = 0 then
	begin
		repeat
			// Exclude directories from the list of files.
			if ((Rec.Attr and faDirectory) <> faDirectory) then Inc(nFileCount);
		until FindNext(Rec) <> 0;
		FindClose(Rec);
	end;
	Result := nFileCount;
end;

function TMainForm.IfThen(AValue: Boolean; const ATrue: Integer; const AFalse: Integer): Integer;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

procedure TMainForm.ChangeState(Enable: Boolean);
begin
  Abort := False;

  pnlMain.Enabled := Enable;
  pnlProcess.Visible := not Enable;
  Label2.Enabled := Enable;
  gbFile.Enabled := Enable;
  lblDir.Enabled := Enable;
  btnSelectDir.Enabled := Enable;
  sgSummary.Enabled := Enable;
  btnAbout.Enabled := Enable;
  btnCancel.Enabled := Enable;
  btnGo.Enabled := Enable;
end;

procedure TMainForm.PrepareHeaders();
var
  a, b: Integer;
const
  TagNames: array[0..3] of String = ('Date Time Original', 'Date Time Digitized', 'Date Time', 'File Date');
begin
  for a := 0 to sgSummary.RowCount - 1 do for b := 1 to sgSummary.ColCount - 1 do sgSummary.Cells[a, b] := '';
  sgSummary.Cells[0, 0] := 'File Name';
  for a := 1 to Length(TagNames) do sgSummary.Cells[a, 0] := TagNames[a - 1];
end;

procedure TMainForm.ParseDir(DirName: String);
var
  iMaxFile, iCntFile, iCntExif, a, b: Integer;
  tmp: String;
  SR: TSearchRec;
const
  TagList: array[0..2] of String = ('DateTimeOriginal', 'DateTimeDigitized', 'DateTime');
begin
  ImgData.BuildList := GenAll;
  iCntFile := 0;
  iCntExif := 0;

  DirName := IncludeTrailingBackSlash(DirName);
  iMaxFile := CountFiles(DirName, FileExtension);

  PrepareHeaders();
  sgSummary.RowCount := iMaxFile + 1;

  if iMaxFile < 1 then
  begin
    Application.MessageBox(PChar('No "' + FileExtension + '" files found in selected folder!'), 'Information...', MB_ICONINFORMATION);
    Exit;
  end;

  ChangeState(False);
  pbMain.Max := iMaxFile;
  Abort := False;

  if (cbTimeZone.ItemIndex <> Timezones.IndexOf('0')) and (lblTimeZone.Enabled) then cbTimeZone.Enabled := True;

  if FindFirst(DirName + FileExtension, faAnyFile, SR) = 0 then
  begin
    repeat
      if (SR.Attr <> faDirectory) then
      begin
        if ((ImgData.ProcessFile(DirName + SR.Name)) and (ImgData.HasMetaData())) then
        begin
          sgSummary.Cells[0, iCntExif + 1] := SR.Name;

          for a := 0 to Length(TagList) - 1 do
          begin
            tmp := ImgData.ExifObj.LookupTagVal(TagList[a]);
            if tmp <> '' then sgSummary.Cells[a + 1, iCntExif + 1] := ConvertDateTime(tmp);
          end;

          tmp := GetFileDate(DirName + SR.Name);
          if tmp <> '' then sgSummary.Cells[4, iCntExif + 1] := tmp;

          Inc(iCntExif);
        end;

        Inc(iCntFile);
        pbMain.Position := iCntFile;
        Application.ProcessMessages();

        if Abort then Break;
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;

  ChangeState(True);

  sgSummary.RowCount := iCntExif + 1;
  btnGo.Enabled := (iCntExif > 0);

  cbTimeZone.Enabled := (iCntExif > 0) and (lblTimeZone.Enabled);

  //SelectionMatrix
  SetLength(SelectionMatrix, sgSummary.RowCount);
  for a := 1 to Length(SelectionMatrix) - 1 do
  begin
    for b := 2 to 4 do SelectionMatrix[a, b] := 0;
    SelectionMatrix[a, 1] := 1;
  end;

  lblDir.Caption := DirName;

  FormResize(self);

  if iCntFile <> iCntExif then Application.MessageBox(PChar('Found ' + IntToStr(iCntFile) + ' JPG/JPEG files. ' + IntToStr(iCntExif) + ' of them contains EXIF data.'), 'Information...', MB_ICONINFORMATION);
end;

function TMainForm.GetFileDate(TheFileName: String): String;
var
  f: integer;
begin
  f := FileOpen(TheFileName, 0);
  try
    Result := DateTimeToStr(FileDateToDateTime(FileGetDate(f)));
  finally
    FileClose(f);
  end;
end;

function TMainForm.SetFileDate(FileName: string; Value: TDateTime): String;
var
  iResult: Integer;
begin
  Result := '';
  iResult := FileSetDate(FileName, DateTimeToFileDate(Value));

  if iResult <> 0 then Result := SysErrorMessage(iResult);
end;

function TMainForm.ConvertDateTime(DateTime: String): String;
var
  sDate, sTime: String;
  tdTemp: TDateTime;
  dShift: Single;
begin
  sDate := '';
  sTime := '';

  if Pos(' ', DateTime) > 0 then
  begin
    sDate := Copy(DateTime, 1, Pos(' ', DateTime) - 1);
    sTime := Copy(DateTime, Pos(' ', DateTime) + 1, Length(DateTime));
  end;

  sDate := StringReplace(sDate, ':', '-', [rfReplaceAll]);

  try
    //https://stackoverflow.com/a/31356362/1469208
    //http://docwiki.embarcadero.com/Libraries/XE2/en/System.Variants.VarToDateTime
    //
    //tdTemp := StrToDateTime(sDate + ' ' + sTime);
    tdTemp := VarToDateTime(sDate + ' ' + sTime);

    if ((cbTimeZone.Enabled) and (sTime <> '')) then
    begin
      dShift := StrToFloatDef(Timezones[cbTimeZone.ItemIndex], 0);
      tdTemp := IncMinute(tdTemp, Round(dShift * 60));
    end;

    Result := DateTimeToStr(tdTemp);
  except
    Result := DateTime;
  end;
end;

procedure TMainForm.FormResize(Sender: TObject);
var
  iMaxWidth, a: Integer;
begin
  iMaxWidth := 0;

  for a := 0 to sgSummary.RowCount - 1 do if iMaxWidth < sgSummary.Canvas.TextWidth(sgSummary.Cells[0, a]) then iMaxWidth := sgSummary.Canvas.TextWidth(sgSummary.Cells[0, a]);

  Inc(iMaxWidth, 7);
  sgSummary.ColWidths[0] := iMaxWidth;

  iMaxWidth := (sgSummary.Width - 24 - iMaxWidth) div 4;
  if iMaxWidth < 130 then iMaxWidth := 130;

  for a := 1 to 4 do sgSummary.ColWidths[a] := iMaxWidth;

  CenterControl(MainForm, pnlProcess, True, True, 0);
end;

procedure TMainForm.btnSelectDirClick(Sender: TObject);
var
  DataFolderDialog: TFolderDialog;
begin
  DataFolderDialog := TFolderDialog.Create(MainForm);

  if DirectoryExists(lblDir.Caption) then
    DataFolderDialog.Directory := lblDir.Caption
  else
    DataFolderDialog.Directory := ExtractFilePath(Application.ExeName);

  DataFolderDialog.Caption := 'Select a Folder';
  DataFolderDialog.Title := 'Select a folder containing JPG/JPEG files with EXIF data...';
  DataFolderDialog.Options := [fdoReturnOnlyFSDirs, fdoStatusText, fdoDontgoBelowDomain, fdoNewDialogStyle, fdoNoNewFolderButton];

  if DataFolderDialog.Execute then ParseDir(DataFolderDialog.Directory);

  DataFolderDialog.Free();
end;

procedure TMainForm.btnCancelClick(Sender: TObject);
begin
  Application.Terminate();
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  ini: TINIFile;
  sDir: String;
begin
  ini := TINIFile.Create(ExtractFilePath(Application.ExeName) + 'WindowsSucks.ini');

  if DirectoryExists(lblDir.Caption) then
     sDir := lblDir.Caption
  else
     sDir := ExtractFilePath(Application.ExeName);

  ini.WriteString('Main', 'LastDir', sDir);

  ini.WriteInteger('Main', 'Top', MainForm.Top);
  ini.WriteInteger('Main', 'Left', MainForm.Left);
  ini.WriteInteger('Main', 'Width', MainForm.Width);
  ini.WriteInteger('Main', 'Height', MainForm.Height);

  ini.WriteInteger('Main', 'LastTZ', cbTimeZone.ItemIndex);

  ini.Free();
  ImgData.Free();
  Timezones.Free();
end;

procedure TMainForm.cbTimeZoneChange(Sender: TObject);
begin
  ParseDir(lblDir.Caption);
end;

procedure TMainForm.sgSummaryDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  iMargin: Integer;
begin
  with sgSummary.Canvas do
  begin
    if ACol > 0 then
      iMargin := ((Rect.Right - Rect.Left) div 2) - (TextWidth(sgSummary.Cells[ACol, ARow]) div 2)
    else
      iMargin := 3;

    Pen.Color := clBlack;

    Brush.Color := clWhite;
    if (ACol = 0) or (ARow = 0) then Brush.Color := clBtnFace;
    if SelectionMatrix[ARow, ACol] = 1 then Brush.Color := clAqua;

    FillRect(Rect);

    if ARow = 0 then Font.Style := [fsBold];

    if SelectionMatrix[ARow, ACol] = 1 then
    begin
      Pen.Color := clNavy;
      Rectangle(Rect);
    end;

    TextOut(Rect.Left + iMargin, Rect.Top + 1, sgSummary.Cells[ACol, ARow]);

    if (ACol = 0) or (ARow = 0) then
    begin
      Pen.Color := clWindow;
      MoveTo(Rect.Left, Rect.Top);
      LineTo(Rect.Right, Rect.Top);
      MoveTo(Rect.Left, Rect.Top);
      LineTo(Rect.Left, Rect.Bottom);

      Pen.Color := clScrollBar;
      MoveTo(Rect.Right - 1, Rect.Bottom - 1);
      LineTo(Rect.Right - 1, Rect.Top);
      MoveTo(Rect.Right - 1, Rect.Bottom - 1);
      LineTo(Rect.Left, Rect.Bottom - 1);
    end;
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  SetLength(SelectionMatrix, sgSummary.RowCount);

  PrepareHeaders();
end;

procedure TMainForm.sgSummarySelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
  a, b: Integer;
  WasSelected: Boolean;
begin
  if (ACol > 0) and (ARow > 0) then
  begin
    WasSelected := (SelectionMatrix[ARow, ACol] = 1);

    for b := 1 to 4 do SelectionMatrix[ARow, b] := 0;

    SelectionMatrix[ARow, ACol] := IfThen(WasSelected, 0, 1);
  end
  else
  begin
    if (ARow = 0) and (aCol > 0) then
    begin
      for a := 1 to sgSummary.RowCount - 1 do
      begin
        for b := 1 to 4 do SelectionMatrix[a, b] := 0;
        SelectionMatrix[a, ACol] := 1;
      end;
    end;
  end;

  sgSummary.Repaint();
end;

procedure TMainForm.btnAboutClick(Sender: TObject);
begin
  InfoForm.ShowModal();
end;

procedure TMainForm.CenterControl(ParentObject, CenterObject: TControl; bTop, bLeft: Boolean; Space: Integer);
begin
  with CenterObject do
  begin
    if bLeft then
      Left := ParentObject.Width div 2 - Width div 2 + Space;

    if bTop then
      Top := ParentObject.Height div 2 - Height div 2;
  end;
end;

procedure TMainForm.btnGoClick(Sender: TObject);
var
  a, b, iSel, iCnt: Integer;
  sMessage, sResult, sDate, sFile: String;
  dtDate: TDateTime;
begin
  ChangeState(False);
  pbMain.Max := sgSummary.RowCount - 1;
  iCnt := 0;

  for a := 1 to sgSummary.RowCount - 1 do
  begin
    iSel := 0;

    for b := 1 to 4 do if SelectionMatrix[a, b] = 1 then iSel := b;

    if iSel > 0 then
    begin
      sDate := sgSummary.Cells[iSel, a];
      sFile := lblDir.Caption + sgSummary.Cells[0, a];

      try
        //https://stackoverflow.com/a/31356362/1469208
        //http://docwiki.embarcadero.com/Libraries/XE2/en/System.Variants.VarToDateTime
        //
        //dtDate := StrToDateTime(sDate);
        dtDate := VarToDateTime(sDate);
        sResult := SetFileDate(sFile, dtDate);
      except
        if Application.MessageBox(PChar('It got pretty fucked up for row ' + IntToStr(a) + ', when trying to read/convert date!' + #10#13 + #10#13 + 'Abort now?'), 'Houston, we have a problem!', MB_ICONERROR + MB_YESNO + MB_DEFBUTTON2) = IDYES then Break;
        Continue;
      end;

      if sResult <> '' then if Application.MessageBox(PChar('It got pretty fucked up for file "' + sFile + '"!' + #10#13 + #10#13 + 'When trying to change file date, got system error saying: "' + sResult + '"' + #10#13 + #10#13 + 'Abort now?'), 'Houston, we have a problem!', MB_ICONERROR + MB_YESNO + MB_DEFBUTTON2) = IDYES then Break;

      Inc(iCnt);
      pbMain.Position := a;
      Application.ProcessMessages();

      if Abort then Break;
    end;
  end;

  ChangeState(True);
  ParseDir(lblDir.Caption);

  if iCnt > 0 then
  begin
    sMessage := 'Done! Changed date of ' + IntToStr(iCnt) + ' file';
    if pbMain.Position > 1 then sMessage := sMessage + 's';
    sMessage := sMessage + ' out of ' + IntToStr(pbMain.Position) + ' total. Have a nice day! :)';
    Application.MessageBox(PChar(sMessage), 'Done!', MB_ICONINFORMATION);
  end;

  sgSummary.Invalidate();
end;

procedure TMainForm.btnAbortClick(Sender: TObject);
begin
  Abort := True;
end;

end.
