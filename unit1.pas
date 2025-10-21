unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, IdHTTP,
  IdSSLOpenSSL, IdDayTime;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    edtPath: TEdit;
    edtSenha: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FCertPassword: string;
    procedure GetPassword(var APassword: string);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.Button1Click(Sender: TObject);
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  Resp: TStringStream;
  CertFile, CertKey: string;
begin
   // Caminhos e senha do certificado A1

  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  Resp := TStringStream.Create;


  try
    // Configura o SSL
    SSL.SSLOptions.Method := sslvTLSv1_2;
    SSL.SSLOptions.Mode := sslmClient; //sslmUnassigned;
    SSL.SSLOptions.VerifyMode := [];
    SSL.SSLOptions.VerifyDepth := 0;

    // Para PFX, use a função de importação via store:
    SSL.SSLOptions.CertFile := edtPath.Text;
    SSL.SSLOptions.KeyFile := edtPath.Text;
    SSL.SSLOptions.RootCertFile := '';
    SSL.OnGetPassword := @GetPassword;
    //SSL.LoadCertFromPFX(CertFile, CertPassword);

    // Liga o SSL ao HTTP
    HTTP.IOHandler := SSL;
    HTTP.Request.ContentType := 'application/json';
    HTTP.Request.Accept := 'application/json';
    HTTP.Request.UserAgent := 'Delphi-Indy Client';

    // Faz a requisição GET (ou POST, conforme necessário)
    HTTP.Get('https://cff.svrs.rs.gov.br/api/v1/consultas/classTrib', Resp);

    // Exibe a resposta JSON
    Memo1.Lines.Clear;
    Memo1.Lines.Add('Consulta realizada com sucesso!');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('--- Retorno JSON ---');
    Memo1.Lines.Add(UTF8Decode(RawByteString(Resp.Bytes)));

  except
    on E: Exception do
    begin
      Memo1.Lines.Add('Erro ao consultar o endpoint:');
      Memo1.Lines.Add(E.Message);
    end;
  end;

  Resp.Free;
  SSL.Free;
  HTTP.Free;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  memo1.Lines.Clear;
end;

procedure TForm1.GetPassword(var APassword: string);
begin
  APassword := edtSenha.Text;
end;

end.

