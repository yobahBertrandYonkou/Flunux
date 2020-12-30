import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class CommandLine extends StatefulWidget {
  @override
  _CommandLineState createState() => _CommandLineState();
}

class _CommandLineState extends State<CommandLine> {
  var fsconnect = FirebaseFirestore.instance;
  var _controller = TextEditingController();
  var consoleOutput;
  var cmdText;
  int statusCode;
  bool _isAsyncCall = false;
  var documents;

  dataHandler(dynamic data, String cmd, String userId) {
    DateTime now = new DateTime.now();
    var finalData = {
      "command": {
        "cmd": cmd,
        "output": data["output"],
        "exit-code": data["status"]
      },
      "date-time": new DateTime(now.year, now.month, now.day, now.hour,
          now.minute, now.second, now.millisecond),
      "user-id": userId,
    };

    try {
      fsconnect.collection("flunux-$userId").add(finalData);
      print("Successfully pushed");
    } catch (e) {
      print("\n\n#####################\n $e \n###################\n\n");
    }
  }

  apiGuru(var cmd) async {
    setState(() {
      if (cmd.indexOf("sudo") == -1) {
        cmdText = cmd = ("sudo " + cmd).trim().toLowerCase();
      }
    });

    var url = "http://65.0.113.228/cgi-bin/?cmd=${cmd}";
    print(url);
    var response = await http.get(url);
    var userId = "1941146";
    var decoded = jsonDecode(response.body);

    dataHandler(decoded[0], cmd, userId);

    await fsconnect
        .collection("flunux-1941146")
        .orderBy("date-time")
        .get()
        .then((value) => {
              setState(() {
                consoleOutput =
                    value.docs[value.size - 1].data()["command"]["output"];
                _isAsyncCall = false;
              })
            })
        .catchError((onError) => print("This is the error received: $onError"));
  }

  cardPlacer(cmd, desc) {
    return Card(
      color: const Color(0xFF30475e),
      child: ListTile(
        onTap: () {
          setState(() {
            cmdText = cmd.trim().toLowerCase();
          });
          Navigator.pop(context);
        },
        onLongPress: () {
          var alert = AlertDialog(
            elevation: 15,
            backgroundColor: const Color(0xFFf2a365),
            title: Text("Command Description"),
            content: Text(
              desc,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              RaisedButton(
                color: const Color(0xFF30475e),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              )
            ],
          );

          showDialog(
              context: context,
              builder: (BuildContext context) {
                return alert;
              });
        },
        title: Text(
          cmd,
          style: TextStyle(
            fontFamily: "courier new",
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  cmdGroup(title) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
        color: const Color(0xFF30475e),
        width: 2,
      )),
      alignment: Alignment.center,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontFamily: "courier new",
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var myDrawer = Drawer(
      child: Container(
        color: const Color(0xFFf2a365),
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  CircleAvatar(
                    radius: 55,
                    child: Image.asset("images/photo.png"),
                  ),
                  Text("REDHAT LINUX 8.0"),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            cmdGroup("FILE COMMANDS"),
            SizedBox(
              height: 20,
            ),
            cardPlacer("ls", "directory listing"),
            cardPlacer("ls -al", "formatted listing with hidden files"),
            cardPlacer("cd dir", "change directory to dir"),
            cardPlacer("cd", "change to home"),
            cardPlacer("pwd", "show current directory"),
            cardPlacer("mkdir dir", "create a directory dir"),
            cardPlacer("rm file", "delete file"),
            cardPlacer("rm -r dir", "delete directory dir"),
            cardPlacer("rm -f file", "force remove file"),
            cardPlacer("rm -rf dir", "force remove directory dir"),
            cardPlacer("cp file1 file2", "copy file1 to file2"),
            cardPlacer("cp -r dir1 dir2",
                "copy dir1 to dir2, create dir2 if it doesn't exist"),
            cardPlacer("mv file1 file2",
                "rename or move file1 to file2 if file2 is an existing directory, moves file1 into directory file2"),
            cardPlacer("ln -s file link", "create symbolic link link to file"),
            cardPlacer("touch file", "create or update file"),
            cardPlacer("cat > file", "places standard input into file"),
            cardPlacer("more file", "output the contents of file"),
            cardPlacer("head file", "output the first 10 lines of file"),
            cardPlacer("tail file", "output the last 10 lines of file"),
            cardPlacer("tail -f file",
                "output the contents of file as it grows, starting witht he last 10 lines"),
            SizedBox(
              height: 20,
            ),
            cmdGroup("PROCESS MANAGEMENT"),
            SizedBox(
              height: 20,
            ),
            cardPlacer("ps", "display your currently active processes"),
            cardPlacer("top", "display all running processes"),
            cardPlacer("kill pid", "kill process id pid"),
            cardPlacer("killall proc", "kill all processes named proc"),
            cardPlacer("bg",
                "lists stopped or background jobs; resume a stopped job in the background"),
            cardPlacer("fg", "brings the most recent job to foreground"),
            cardPlacer("fg n", "brings job n to the foreground"),
            SizedBox(
              height: 20,
            ),
            cmdGroup("FILE PERMISSIONS"),
            SizedBox(
              height: 20,
            ),
            cardPlacer("chmod octal file",
                "change the permissions of file to octal, which can be found separately for user, group, and world by adding:\n=> 4 - read (r)\n=> 2 - write (w)\n=> 1 - execute (x)Examples:\nchmod 777 – read, write, execute for all\nchmod 755 – rwx for owner, rx for group and world\nFor more options, see man chmod"),
            SizedBox(
              height: 20,
            ),
            cmdGroup("SEARCHING"),
            SizedBox(
              height: 20,
            ),
            cardPlacer("grep pattern files", "search for pattern in files"),
            cardPlacer(
                "grep -r pattern dir", "search recursively for pattern in dir"),
            cardPlacer("command | grep pattern",
                "search for pattern in the output of command"),
            cardPlacer("locate file", "find all instances of file"),
            SizedBox(
              height: 20,
            ),
            cmdGroup("SYSTEM INFO"),
            SizedBox(
              height: 20,
            ),
            cardPlacer("date", "show the current date and time"),
            cardPlacer("cal", "show this month's calendar"),
            cardPlacer("uptime", "show current uptime"),
            cardPlacer("w", "display who is online"),
            cardPlacer("whoami", "who you are logged in as"),
            cardPlacer("uname -a", "show kernel information"),
            cardPlacer("cat /proc/cpuinfo", "cpu information"),
            cardPlacer("cat /proc/meminfo", "memory information"),
            cardPlacer("man command", "show the manual for command"),
            cardPlacer("df", "show disk usage"),
            cardPlacer("du", "show directory space usage"),
            cardPlacer("free", "show memory and swap usage"),
            cardPlacer("whereis app", "show possible locations of app"),
            cardPlacer("which app", "show which app will be run by default"),
          ],
        ),
      ),
    );

    var body = Container(
        width: MediaQuery.of(context).size.width * 0.95,
        margin: EdgeInsets.only(
          top: 15,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF30475e),
          boxShadow: [
            BoxShadow(
                blurRadius: 15, offset: Offset(2, 3), color: Colors.black54),
          ],
        ),
        child: Column(
          children: <Widget>[
//textbox for entering commands
            Container(
              child: TextField(
                onSubmitted: (value) {
                  _isAsyncCall = true;
                  apiGuru(cmdText);
                },
                controller: _controller
                  ..text = cmdText
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: _controller.text.length),
                  ),
                style: TextStyle(
                    fontFamily: 'Courier New',
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                enableInteractiveSelection: true,
                onChanged: (value) {
                  cmdText = value;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.code,
                    color: const Color(0xFFf2a365),
                  ),
                  suffixIcon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: const Color(0xFFf2a365),
                      ),
                      onPressed: () {
                        _controller.clear();
                        _controller.clear();
                      }),
                  hintText: "Enter your commands here...",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                cursorColor: Colors.redAccent,
                autofocus: false,
                autocorrect: false,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Output Console",
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Courier new",
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 10,
            ),
//commandline view/output console
            Container(
              padding: EdgeInsets.only(
                top: 5,
                left: 5,
              ),
              margin: EdgeInsets.only(
                top: 5,
              ),
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: ModalProgressHUD(
                inAsyncCall: _isAsyncCall,
                color: Colors.black,
                progressIndicator: CircularProgressIndicator(),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      consoleOutput ?? "No output...",
                      style: TextStyle(
                        fontFamily: 'Courier New',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
    return Scaffold(
      drawer: myDrawer,
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        splashColor: const Color(0xFF30475e),
        icon: Icon(Icons.directions_run),
        elevation: 15,
        onPressed: () => {
          setState(() {
            _isAsyncCall = true;
            apiGuru(cmdText);
          })
        },
        label: Text("Execute"),
        backgroundColor: const Color(0xFFf2a365),
      ),
      backgroundColor: const Color(0xFFececec),
      body: SingleChildScrollView(child: Center(child: body)),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf2a365),
        title: Text(
          "B.M.B FLUNUX",
          style: TextStyle(
              fontFamily: "Courier new",
              fontWeight: FontWeight.bold,
              fontSize: 24),
        ),
      ),
    );
  }
}
