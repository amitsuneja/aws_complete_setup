import winrm
session = winrm.Session("34.234.96.174", auth=('administrator','Welcome@0987'))
result = session.run_ps("hostname")
print(result.std_out)
