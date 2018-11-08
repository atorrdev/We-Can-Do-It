<#
Aplicación que permite que un usuario sin privilegios ejecute una aplicacion con credenciales de administrador
Recibe 4 parametros de entrada
Usuario, password, aplicacion a ejecutar y directorio donde se dejaran los ficheros encargados de ejecutar el script final

Genera carpeta con 5 ficheros en el directorio elegido con el nombre de la aplicacion a ejecutar:

-Fichero usuario.txt con el usuario en texto plano
-Fichero password.txt con la password encriptada
-Fichero "aplicacion".exe.txt con el nombre de la aplicacion a ejecutar en texto plano
-Fichero "aplicacion".exe.ps1 con el script que permite la ejecucion de la aplicacion con las credenciales indicadas.
-Fichero "aplicacion".exe.bat que permite la ejecucion del PS1 saltandose la limitacion de powershell de no ejecutar scripts y abrir el editor (un enlace a este fichero es el que abria que darle al usuario final)


-Aviso-
Puede ser necesario cambiar la politica de ejecución de scripts de Powershell de restricted. Lo mas conveniente es poner remote signed.
Set-ExecutionPolicy RemoteSigned

-Aviso-
La carpeta con el resultado final del script debe guardarse en un directorio donde se tengan permisos para ejecutar.
Ej: Si guardamos la carpeta en el escritorio del usuario "pepito" y las credenciales de ejecucion que hemos elegido son "pepito_admin", dara un error de directorio no encontrado.

27_06_2015
#>

Function ejecuta(){
        
        

        if ((-Not $objTextBoxUsuario.Text) -or (-Not $objTextBoxPassword.Text) -or (-Not $objTextBoxFichero.Text) -or (-Not $objTextBoxScript.Text)  ){
                $objLabelMensaje.Text = "Faltan datos"												
		        $objLabelMensaje.ForeColor="Red" 
        }
        else
        {
            $direc_fichero=$objTextBoxFichero.Text
            $direc_script=$objTextBoxScript.Text
        
            $usuario=$objTextBoxUsuario.Text       
            $password=ConvertTo-SecureString -string $objTextBoxPassword.Text  -AsPlainText -Force

            $usuario=$usuario -replace (" ","")           


            $aplicacion=Split-Path $direc_fichero -Leaf

            $directorio_final=$direc_script
            $directorio_final+="\"
            $directorio_final+=$aplicacion

            if (Test-Path $directorio_final){
               $objLabelMensaje.Text = "El directorio ya existe"												
		       $objLabelMensaje.ForeColor="Red"
            }
            else
            {
                                    
                $directorio_usuario=$directorio_final
                $directorio_usuario+="\"
                $directorio_usuario+=$usuario
                $directorio_usuario+=".txt"

                $directorio_password=$directorio_final
                $directorio_password+="\"
                $directorio_password+="password"
                $directorio_password+=".txt"

                $directorio_aplicacion=$directorio_final
                $directorio_aplicacion+="\"
                $directorio_aplicacion+=$aplicacion
                $directorio_aplicacion+=".txt"

                $directorio_ps1=$directorio_final
                $directorio_ps1+="\"
                $directorio_ps1+=$aplicacion
                $directorio_ps1+=".ps1"

                $directorio_bat=$directorio_final
                $directorio_bat+="\"
                $directorio_bat+=$aplicacion
                $directorio_bat+=".bat"
       

                New-Item -ItemType directory -Path $directorio_final
                New-Item -ItemType file -Path $directorio_usuario
                New-Item -ItemType file -Path $directorio_password
                New-Item -ItemType file -Path $directorio_ps1
                New-Item -ItemType file -Path $directorio_aplicacion
        
             

                $usuario |Set-Content $directorio_usuario
                $password |ConvertFrom-SecureString |Set-Content $directorio_password
                $objTextBoxFichero.Text |Set-Content $directorio_aplicacion



                $pr = "`$p=Get-Content " + $directorio_password+ "| ConvertTo-SecureString"# -asplaintext -force"
                $ur= "`$u=Get-Content " +$directorio_usuario
                $ar="`$a=Get-Content " +$directorio_aplicacion
                $cr = "`$c=New-Object System.Management.Automation.PsCredential `$u,`$p"        
                $ejecutar="Start-Process -FilePath `$a -Credential `$c "


                $pr >> $directorio_ps1
                $ur >>  $directorio_ps1
                $ar >>  $directorio_ps1
                $cr >>  $directorio_ps1
                $ejecutar >> $directorio_ps1

        
                $script_ps1=Split-Path $directorio_ps1 -Leaf
                "powershell .\$script_ps1" |out-file $directorio_bat  -Encoding ascii        


                 $objLabelMensaje.Text = "Finalizado"												
		         $objLabelMensaje.ForeColor="Green"

           

            }#Else el directorio ya existe

        }# Else Faltan datos
}

Clear-Host
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.windows.Forms")


$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "We Can Do It"
$objForm.Size = New-Object System.Drawing.Size(100,100) 
$objForm.StartPosition = "CenterScreen"
$objForm.AutoSize=$true
$objForm.AutoSizeMode="GrowAndShrink"
$objForm.MaximizeBox=$false
$objForm.MinimizeBox=$false
$objForm.WindowState="Normal"

$objForm.SizeGripStyle="Hide"

$objForm.KeyPreview = $True


$dirscript=""
$diraplicacion=""


$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
						{						
                        ejecuta																				
						} #fin de pulsar tecla enter
					}) #fin de pulsar
					
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") {$objForm.Close()}})



 #####Usuario####
        $objLabelUsuario = New-Object System.Windows.Forms.Label
        $objLabelUsuario.Location = New-Object System.Drawing.Size(30,20) 
        $objLabelUsuario.Size = New-Object System.Drawing.Size(280,20)         
        $objLabelUsuario.Text = "Usuario:"		
        $objForm.Controls.Add($objLabelUsuario) 
        $objTextBoxUsuario = New-Object System.Windows.Forms.TextBox 
        $objTextBoxUsuario.Location = New-Object System.Drawing.Size(30,40) 
        $objTextBoxUsuario.Size = New-Object System.Drawing.Size(260,20)        		
        $objForm.Controls.Add($objTextBoxUsuario) 
        ################

#####Password####
        $objLabelPassword = New-Object System.Windows.Forms.Label
        $objLabelPassword.Location = New-Object System.Drawing.Size(30,70) 
        $objLabelPassword.Size = New-Object System.Drawing.Size(280,20) 
        $objLabelPassword.Text = "Password:"		
        $objForm.Controls.Add($objLabelPassword) 
        #$objTextBoxPassword = New-Object System.Windows.Forms.TextBox 
        $objTextBoxPassword = New-Object System.Windows.Forms.MaskedTextBox
        $objTextBoxPassword.PasswordChar="*" 
        $objTextBoxPassword.Location = New-Object System.Drawing.Size(30,90) 
        $objTextBoxPassword.Size = New-Object System.Drawing.Size(260,20)       		
        $objForm.Controls.Add($objTextBoxPassword) 
        ################


#####Aplicación a ejectuar####
$objLabelFichero = New-Object System.Windows.Forms.Label
$objLabelFichero.Location = New-Object System.Drawing.Size(10,120) 
$objLabelFichero.Size = New-Object System.Drawing.Size(280,20) 
#$objLabelFichero.ForeColor="DarkBlue"
$objLabelFichero.Text = "Aplicacion a ejecutar"
$objForm.Controls.Add($objLabelFichero) 

$objTextBoxFichero = New-Object System.Windows.Forms.TextBox                 
$objTextBoxFichero.Location = New-Object System.Drawing.Size(10,140) 
$objTextBoxFichero.Size = New-Object System.Drawing.Size(200,20)
$objTextBoxFichero.Text=""
$objForm.Controls.Add($objTextBoxFichero)

$objBuscarButton=New-Object System.Windows.Forms.Button 
$objBuscarButton.Location= New-Object System.Drawing.Size(220,140)
$objBuscarButton.Size = New-Object System.Drawing.Size(75,23)
$objBuscarButton.Text="Explorar..."
$objForm.Controls.Add($objBuscarButton)

$objBuscarButton.Add_Click({                    										
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
        [void]$FileBrowser.ShowDialog()
        $diraplicacion=$FileBrowser.filename      
        $objTextBoxFichero.Text=$diraplicacion     #Pinto el directorio elegido
					})
$objForm.Controls.Add($objBuscarButton)
################


#####Directorio script####
$objLabelScript = New-Object System.Windows.Forms.Label
$objLabelScript.Location = New-Object System.Drawing.Size(10,170) 
$objLabelScript.Size = New-Object System.Drawing.Size(280,20) 
#$objLabelScript.ForeColor="DarkBlue"
$objLabelScript.Text = "Directorio de salida del script"
$objForm.Controls.Add($objLabelscript) 

$objTextBoxScript = New-Object System.Windows.Forms.TextBox                 
$objTextBoxScript.Location = New-Object System.Drawing.Size(10,190) 
$objTextBoxScript.Size = New-Object System.Drawing.Size(200,20)
$objTextBoxScript.Text=""
$objForm.Controls.Add($objTextBoxScript)

$objScriptButton=New-Object System.Windows.Forms.Button 
$objscriptButton.Location= New-Object System.Drawing.Size(220,190)
$objScriptButton.Size = New-Object System.Drawing.Size(75,23)
$objScriptButton.Text="Explorar..."
$objForm.Controls.Add($objscriptButton)

$objScriptButton.Add_Click({                    										
        Add-Type -AssemblyName System.Windows.Forms
        $FolderBrowserScript = New-Object System.Windows.Forms.FolderBrowserDialog
        [void]$FolderBrowserScript.ShowDialog()
        $dirscript=$FolderBrowserScript.SelectedPath       
        $objTextBoxScript.Text=$dirscript     #Pinto el directorio elegido
        
					})
$objForm.Controls.Add($objScriptButton)
################


#####Mensaje####
$objLabelMensaje = New-Object System.Windows.Forms.Label
$objLabelMensaje.Location = New-Object System.Drawing.Size(10,210) 
#$objLabelMensaje.Size = New-Object System.Drawing.Size(280,20) 
$objLabelMensaje.AutoSize=$true
$objLabelMensaje.Text = ""
$objForm.Controls.Add($objLabelMensaje) 



#### BOTON ACEPTAR ####
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(80,230)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "Aceptar"
$OKButton.Add_Click({
					ejecuta	       				
					})
$objForm.Controls.Add($OKButton)

#### BOTON CANCELAR ####
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(155,230)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancelar"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

#### El formulario se muestra encima de todo####
$objForm.Topmost = $True

#### Se activa y se muestra el formulario ####
$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()