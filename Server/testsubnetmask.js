//ifconfig interface_name | grep 'inet '

try{
	var wsh = new ActiveXObject('Shell.Application');
} catch(err){
	console.log("It didn't work");
	console.log(err);
} 

function runip() 
{ 
wsh.ShellExecute("C:\\WINDOWS\\system32\\ip... ", 
"", "open", "1"); 
} 



