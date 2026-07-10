unit Horse.CORS;

{$IF DEFINED(FPC)}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  {$IF DEFINED(FPC)}
    SysUtils,
  {$ELSE}
    System.SysUtils,
  {$ENDIF}
  Horse;

type
  PHorseCORSConfig = ^HorseCORSConfig;

  HorseCORSConfig = record
  public
    function AllowedOrigin(AAllowedOrigin: string): PHorseCORSConfig;
    function AllowedCredentials(AAllowedCredentials: Boolean): PHorseCORSConfig;
    function AllowedHeaders(AAllowedHeaders: string): PHorseCORSConfig;
    function AllowedMethods(AAllowedMethods: string): PHorseCORSConfig;
    function ExposedHeaders(AExposedHeaders: string): PHorseCORSConfig;
  end;

function HorseCORS(): HorseCORSConfig; overload;
procedure CORS(Req: THorseRequest; Res: THorseResponse; Next: {$IF DEFINED(FPC)}TNextProc{$ELSE}TProc{$ENDIF}); overload;

implementation

uses
  {$IF DEFINED(FPC)}
    httpdefs, StrUtils,
  {$ELSE}
    Web.HTTPApp, System.StrUtils,
  {$ENDIF}
  Horse.Commons;

var
  LAllowedOrigin: string;
  LAllowedCredentials: string;
  LAllowedHeaders: string;
  LAllowedMethods: string;
  LExposedHeaders: string;

procedure CORS(Req: THorseRequest; Res: THorseResponse; Next: {$IF DEFINED(FPC)}TNextProc{$ELSE}TProc{$ENDIF});
var
  LAlloweds: TArray<String>;
  LAllowed, LOrigin: String;
  LMatch: Boolean;
  i: Integer;
begin
  LAllowed := LAllowedOrigin;
  LOrigin := Req.Headers['Origin'];

  if Trim(LOrigin) = '' then
    LOrigin := '*';

  if LAllowed <> '*' then
  begin
    LAlloweds := LAllowed.Split([',', ';', ' '], TStringSplitOptions.ExcludeEmpty);
    LMatch := False;

    for i := Low(LAlloweds) to High(LAlloweds) do
      if SameText(LAlloweds[i], LOrigin) then
      begin
        LMatch := True;
        Break;
      end;

    if not LMatch then
      LOrigin := 'null';
  end;

  Res.RawWebResponse.SetCustomHeader('Access-Control-Allow-Origin', LOrigin);
  Res.RawWebResponse.SetCustomHeader('Access-Control-Allow-Credentials', LAllowedCredentials);
  Res.RawWebResponse.SetCustomHeader('Access-Control-Allow-Headers', LAllowedHeaders);
  Res.RawWebResponse.SetCustomHeader('Access-Control-Allow-Methods', LAllowedMethods);
  Res.RawWebResponse.SetCustomHeader('Access-Control-Expose-Headers', LExposedHeaders);
  if Req.RawWebRequest.Method = 'OPTIONS' then
  begin
    Res.Send('').Status(THTTPStatus.NoContent);
    raise EHorseCallbackInterrupted.Create();
  end
  else
    Next();
end;

{ HorseCORS }

function HorseCORSConfig.AllowedCredentials(AAllowedCredentials: Boolean): PHorseCORSConfig;
begin
  Result := @Self;
  LAllowedCredentials := ifthen(AAllowedCredentials, 'true', 'false');
end;

function HorseCORSConfig.AllowedHeaders(AAllowedHeaders: string): PHorseCORSConfig;
begin
  Result := @Self;
  LAllowedHeaders := AAllowedHeaders;
end;

function HorseCORSConfig.AllowedMethods(AAllowedMethods: string): PHorseCORSConfig;
begin
  Result := @Self;
  LAllowedMethods := AAllowedMethods;
end;

function HorseCORSConfig.AllowedOrigin(AAllowedOrigin: string): PHorseCORSConfig;
begin
  Result := @Self;
  LAllowedOrigin := AAllowedOrigin;
end;

function HorseCORSConfig.ExposedHeaders(AExposedHeaders: string): PHorseCORSConfig;
begin
  Result := @Self;
  LExposedHeaders := AExposedHeaders;
end;

function HorseCORS(): HorseCORSConfig;
begin
  Result := Default(HorseCORSConfig);
end;

initialization
  LAllowedOrigin := '*';
  LAllowedCredentials := 'true';
  LAllowedHeaders := '*';
  LAllowedMethods := '*';
  LExposedHeaders := '*';

end.
