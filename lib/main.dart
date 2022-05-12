import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json, base64, ascii;
import 'user.dart';

void main() {
  runApp(MyApp());
}

//get user details from
Future<User?> getUsers() async {
  Future<String?> _token = storage.read(key: "token");
  String? token2 = await storage.read(key: "token").then((value) => value);
  // print(token2);
  // print("Function call");
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'token': "$token2"
  };
  var res = await http.get(Uri.parse("$SERVER_IP/dashboard"), headers: headers);
  if (res.statusCode == 200) {
    print("Get Request Successful");
    var jsonRes = json.decode(res.body);
    var user = User.fromJson(jsonRes);
    return user;
  } else {
    print("Get Request Failed");
    return null;
  }
}

//global variables and functions
void displayDialog(context, title, text) => showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(title: Text(title), content: Text(text)),
    );
const SERVER_IP = "http://10.0.2.2:3000";
final storage = FlutterSecureStorage();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: MyHomePage(),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        // '/login': (context) => MyLoginPage(),
        '/register': (context) => MyRegisterPage(),
        '/addtask': (context) => AddTask(),
        // '/dashboard': (context) => MyDashboardPage(),
      },
    ); //MaterialApp
  }
}

class MyHomePage extends StatefulWidget {
  // MyHomePage({Key? key, required this.title}) : super(key: key);
  // final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // late Future<User?> _user;
  late Future<bool?> isUser;
  Future<bool?> isUserAuth() async {
    Future<String?> _token = storage.read(key: "token");
    String? token2 = await storage.read(key: "token").then((value) => value);
    // print(token2);
    // print("Function call");
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'token': "$token2"
    };
    var res =
        await http.get(Uri.parse("$SERVER_IP/is-verify"), headers: headers);
    if (res.statusCode == 200) {
      print("Get Request Successful bool");
      var jsonRes = json.decode(res.body);
      print(jsonRes);
      return jsonRes;
    } else {
      print("Get Request Failed");
      return false;
    }
  }

  @override
  initState() {
    super.initState();
    isUser = isUserAuth();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: isUser,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == true) {
              return MyDashboardPage();
            } else {
              return MyLoginPage();
            }
          } else {
            return MyLoginPage();
          }
        });
  }
}

class MyLoginPage extends StatelessWidget {
  // const MyLoginPage({Key? key}) : super(key: key);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Log In"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: <Widget>[
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: 'Username'),
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
          ),
          TextButton(
              onPressed: () async {
                var username = _usernameController.text;
                var password = _passwordController.text;
                // print(username + " " + password);
                try {
                  var res = await http.post(Uri.parse("$SERVER_IP/login"),
                      body: {"email": username, "password": password});
                  if (res.statusCode == 200) {
                    // print(res.body);
                    var jsonRes = json.decode(res.body);
                    var token = jsonRes["token"];
                    storage.write(key: "token", value: token);
                    print(token);
                    Navigator.pushReplacementNamed(context, '/');
                  } else if (res.statusCode == 404) {
                    displayDialog(context, "Login Failed", "User Not Found !");
                  } else if (res.statusCode == 401) {
                    displayDialog(
                        context, "Login Failed", "Invalid Password !");
                  } else {
                    displayDialog(context, "Login Failed", "Something Worng !");
                  }
                } catch (e) {
                  print(e);
                }
              },
              child: Text("Log In")),
          TextButton(
              onPressed: () =>
                  {Navigator.pushReplacementNamed(context, '/register')},
              child: Text("Register"))
        ]),
      ),
    );
  }
}

class MyRegisterPage extends StatelessWidget {
  // const MyRegisterPage({Key? key}) : super(key: key);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign up"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: <Widget>[
          TextField(
            controller: _emailController,
            // obscureText: true,
            decoration: InputDecoration(labelText: 'Username'),
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
          ),
          TextField(
            controller: _firstnameController,
            // obscureText: true,
            decoration: InputDecoration(labelText: 'First Name'),
          ),
          TextField(
            controller: _lastnameController,
            // obscureText: true,
            decoration: InputDecoration(labelText: 'Last Name'),
          ),
          TextButton(
              onPressed: () async {
                var email = _emailController.text;
                var password = _passwordController.text;
                var fname = _firstnameController.text;
                var lname = _lastnameController.text;
                try {
                  var res = await http.post(Uri.parse("$SERVER_IP/register"),
                      body: {
                        "email": email,
                        "password": password,
                        "first_name": fname,
                        "last_name": lname
                      });
                  if (res.statusCode == 200) {
                    // print(res.body);
                    var jsonRes = json.decode(res.body);
                    var token = jsonRes["token"];
                    storage.write(key: "token", value: token);
                    Navigator.pushReplacementNamed(context, '/');
                  } else if (res.statusCode == 409) {
                    // print(res.body);
                    displayDialog(
                        context, "Register Failed", "User Already Exists !");
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyHomePage()));
                  } else if (res.statusCode == 401) {
                    displayDialog(context, "Register Failed", res.body);
                    print(res.body);
                    displayDialog(
                        context, "Register Failed", "Something went wrong !");
                  }
                } catch (e) {
                  print(e);
                }
              },
              child: Text("Sign Up"))
        ]),
      ),
    );
  }
}

class MyDashboardPage extends StatefulWidget {
  @override
  State<MyDashboardPage> createState() => _MyDashboardPageState();
}

class _MyDashboardPageState extends State<MyDashboardPage> {
  // const MyDashboardPage({Key? key}) : super(key: key);
  late Future<User?> _user;
  late GlobalKey<ScaffoldState> _scaffoldKey;
  int? reamin;
  final now = DateTime.now();

  void deleteTask(String? id) async {
    try {
      Future<String?> _token = storage.read(key: "token");
      String? token2 = await storage.read(key: "token").then((value) => value);
      Map<String, String> headers = {
        // 'Content-Type': 'application/json',
        'Accept': 'application/json',
        'token': "$token2"
      };
      var res = await http.post(Uri.parse("$SERVER_IP/deletetask"),
          headers: headers, body: {"req_id": id});
      if (res.statusCode == 200) {
        print("Success");
        // displayDialog(context, "Successful", "Task Is added.");
        Navigator.pushReplacementNamed(context, '/');
      } else {
        displayDialog(context, "Something worng", "Task is not deleted.");
        // Navigator.pushReplacementNamed(context, '/taskadd');
      }
    } catch (e) {
      print(e);
      print(id);
    }
  }

  // void deleteTask(int? id) async {
  //   try {

  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override
  initState() {
    super.initState();
    _user = getUsers();
    _scaffoldKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard"), actions: <Widget>[
        IconButton(
            onPressed: () => {
                  storage.delete(key: "token"),
                  Navigator.pushReplacementNamed(context, '/')
                },
            icon: Icon(Icons.logout))
      ]),
      body: RefreshIndicator(
        onRefresh: () async {
          return Future.delayed(Duration(seconds: 1), () {
            Navigator.pushReplacementNamed(context, '/');
            _scaffoldKey.currentState?.showSnackBar(
              SnackBar(
                content: const Text('Page Refreshed'),
              ),
            );
          });
        },
        child: FutureBuilder<User?>(
            future: _user,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                return ListView(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                          "Name: ${snapshot.data?.firstName} ${snapshot.data?.lastName}"),
                    ),
                    ListTile(
                      title: Text("Email: ${snapshot.data?.email}"),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data?.tasks?.length ?? 0,
                            itemBuilder: (BuildContext context, int index) {
                              // var time = DateTime.parse(
                              //     "${snapshot.data?.tasks?.elementAt(index).createdAt}")
                              //   ..subtract(Duration(hours: 6, minutes: 30));
                              var compltime = DateTime.parse(
                                      "${snapshot.data?.tasks?.elementAt(index).completeAt}")
                                  .subtract(Duration(hours: 6, minutes: 30));
                              // var time = Originaltime.subtract(
                              //     Duration(hours: 6, minutes: 30));
                              // var compltime = Completetime.subtract(
                              //     Duration(hours: 6, minutes: 30));

                              return Column(
                                children: [
                                  Card(
                                    child: Card(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          ListTile(
                                            leading: Icon(Icons.notes),
                                            title: Text(
                                                "${snapshot.data?.tasks?.elementAt(index).name}"),
                                            subtitle: Text(
                                                "${snapshot.data?.tasks?.elementAt(index).description}"),
                                          ),
                                          Text(
                                              "${now.hour - compltime.hour}: ${now.minute - compltime.minute} Remaining."),
                                          Text("${compltime.hour}"),
                                          ButtonBarTheme(
                                            // make buttons use the appropriate styles for cards
                                            data: ButtonBarThemeData(),
                                            child: ButtonBar(
                                              children: <Widget>[
                                                TextButton(
                                                  child: const Text("Delete"),
                                                  onPressed: () async {
                                                    deleteTask(snapshot
                                                        .data?.tasks
                                                        ?.elementAt(index)
                                                        .id
                                                        .toString());
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('Edit It'),
                                                  onPressed: () {},
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      elevation: 10,
                                    ),
                                  ),
                                  //   child: Text(
                                  //       "${snapshot.data?.tasks?.elementAt(index).name}"),
                                  // ),
                                  // IconButton(
                                  //     onPressed: () async {

                                  //       deleteTask(snapshot.data?.tasks
                                  //           ?.elementAt(index)
                                  //           .id
                                  //           .toString());
                                  //     },
                                  //     icon: Icon(Icons.delete))
                                ],
                              );
                            })
                      ],
                    )
                  ],
                );
              } else {
                return Center(
                  child: Text("Something went wrong"),
                );
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {Navigator.pushReplacementNamed(context, '/addtask')},
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddTask extends StatefulWidget {
  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  // const AddTask({Key? key}) : super(key: key);
  final TextEditingController _taskName = new TextEditingController();

  final TextEditingController _taskDescription = new TextEditingController();

  TimeOfDay selectTime = TimeOfDay.now();

  _selectTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null && timeOfDay != selectTime) {
      setState(() {
        selectTime = timeOfDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Task"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: <Widget>[
          TextField(
            controller: _taskName,
            decoration: InputDecoration(labelText: 'Task Name'),
          ),
          TextField(
            controller: _taskDescription,
            // obscureText: true,
            decoration: InputDecoration(labelText: 'Task Description'),
          ),
          ElevatedButton(
            onPressed: () {
              _selectTime(context);
            },
            child: Text("Choose Time"),
          ),
          TextButton(
            onPressed: () async {
              var taskname = _taskName.text;
              var taskdesc = _taskDescription.text;
              // print(username + " " + password);
              try {
                // Future<String?> _token = storage.read(key: "token");
                String? token2 =
                    await storage.read(key: "token").then((value) => value);
                // print(token2);
                // print("Function call");
                Map<String, String> headers = {
                  // 'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'token': "$token2"
                };
                var res = await http.post(Uri.parse("$SERVER_IP/addtask"),
                    headers: headers,
                    body: {
                      "name": taskname,
                      "desc": taskdesc,
                      "complete": "${selectTime.hour},${selectTime.minute}"
                    });
                if (res.statusCode == 200) {
                  // displayDialog(context, "Successful", "Task Is added.");
                  Navigator.pushReplacementNamed(context, '/');
                } else {
                  displayDialog(
                      context, "Something worng", "Task is not added.");
                  Navigator.pushReplacementNamed(context, '/taskadd');
                }
              } catch (e) {
                print(e);
              }
            },
            child: Text("Add Task"),
          ),
          TextButton(
            onPressed: () => {Navigator.pushReplacementNamed(context, '/')},
            child: Text("Go To Home"),
          )
        ]),
      ),
    );
  }
}
