title Simple Item Crate Controller Sequence Diagram

Admin->SICC-API:Install Project
note over SICC-API:Generates Database\nAdd Sample Admin Account
SICC-API-->Admin:Send Admin API Key
Admin->SICC-App:Install Mobile App
Admin->SICC-App:Register API Key
SICC-App-->SICC-API:Register Username and Enrollment Token

note over Admin,User:Crate CRUD
Admin->SICC-App:Create a new Crate, Add Items\n(Using API Key for Authentication)

SICC-App-->SICC-API:Register Crate and Items

Admin->SICC-App:Generate QR Code\nPrint it over a physical (real) box

note over Admin,User:Registration Process with QR Code (from Anonymous to User)
User->SICC-App:Scan a QR Code over a box
note over SICC-App:Get SICC-API endpoint url, Admin Enrollment Token, Crate UUID
SICC-App->SICC-API:Authenticate using Admin's Enrollment Token
SICC-API-->User:Asks for Username
User->SICC-API:Send Username, Enrollment Token
note over SICC-API:Register user and generates API Key
SICC-API-->User:Sends User's API Key
note over User:User is registered (can access API read/write)
note over SICC-App:After QR Code Scan and Registration Successful\nAccess to Crate Edit View

note over Admin,User:Registration Process with Admin-Generated API Key (from Anonymous to User)
Admin->User:Sends SICC-API host URL and User's API Key
User->SICC-App:Register API Key
SICC-App-->User:Asks for Username
SICC-App->SICC-API:Register Username and Enrollment Token
SICC-API-->User:Confirm Registration
note over User:User is registered (can access API read/write)