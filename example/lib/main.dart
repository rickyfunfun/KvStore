import 'dart:async';
import 'package:kv_store/kv_store.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_menu/dropdown_menu.dart';
import 'package:random_string/random_string.dart';
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'KvStore Demo',
      theme: new ThemeData(
          primarySwatch: Colors.blue, scaffoldBackgroundColor: Colors.white),
      home: new MyHomePage(title: 'KvStore Demo Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

List<Map<String, dynamic>> actions = [
  {"title": "00: 获取所有表", 'id': 0},
  {"title": "01: 创建默认表", 'id': 1},
  {"title": "02: 创建名为 t_example 的表", "id": 2},
  {"title": "03: 向 t_example 中插入一条随机数据", "id": 3},
  {"title": "04: 从 t_example 清除所有表中数据", "id": 4},
  {"title": "05: 向 t_example 中插入一条 key 为 name 的随机数据", "id": 5},
  {"title": "06: 向 t_example 中插入一条 key 为 city 的随机数据", "id": 6},
  {"title": "07: 向 t_example 中插入一条 key 为 code 的随机数据", "id": 7},
  {"title": "08: 取 t_example 中 key 为 name 的数据", "id": 8},
  {"title": "09: 从 t_example 中删除一条 key 为 name 的数据", "id": 9},
  {"title": "10: 从 t_example 中删除 key 为 [name, city] 的数据", "id": 10},
  {"title": "11: 从 t_example 中删除一条 key 前缀为 c 的数据", "id": 11},
  {"title": "12: 获取 t_example 表中数据的条数", "id": 12},
  {"title": "13: 获取 t_example 表中全部数据", "id": 13},
  {"title": "14: 删除 t_example 表", "id": 14},
];

Future<String> _selecAndRun(int id) async {
  switch (id) {
    case 0:
      return json.encode(await KvStore().allTables());
    case 1:
      return (await KvStore().createTable()).toString();
    case 2:
      return (await KvStore().createTable('t_example')).toString();
    case 3:
      return (await KvStore()
              .putObject(randomAlpha(5), {'data': randomAlpha(5)}, 't_example'))
          .toString();
    case 4:
      return (await KvStore().clearTable('t_example')).toString();
    case 5:
      return (await KvStore()
              .putObject('name', {'data': randomAlpha(5)}, 't_example'))
          .toString();
    case 6:
      return (await KvStore()
              .putObject('city', {'data': randomAlpha(5)}, 't_example'))
          .toString();
    case 7:
      return (await KvStore()
              .putObject('code', {'data': randomAlpha(5)}, 't_example'))
          .toString();
    case 8:
      return JsonEncoder.withIndent('    ')
          .convert(await KvStore().getObjectByKey('name', 't_example'));
    case 9:
      return (await KvStore().deleteObjectByKey('name', 't_example'))
          .toString();
    case 10:
      return (await KvStore()
              .deleteObjectsByKeys(['name', 'city'], 't_example'))
          .toString();
    case 11:
      return (await KvStore().deleteObjectsByKeyPrefix('c', 't_example'))
          .toString();

    case 12:
      return (await KvStore().getCountFromTable('t_example')).toString();
    case 13:
      return JsonEncoder.withIndent('    ')
          .convert(await KvStore().getAllItems('t_example'));
    case 14:
      return (await KvStore().dropTable('t_example')).toString();
  }

  return 'NotFound';
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController scrollController;
  List<Widget> datasource = [];
  int sn = 0;

  @override
  void initState() {
    scrollController = new ScrollController();
    globalKey = new GlobalKey();
    super.initState();
  }

  DropdownMenu buildDropdownMenu() {
    return new DropdownMenu(maxMenuHeight: kDropdownMenuItemHeight * 10,
        //  activeIndex: activeIndex,
        menus: [
          new DropdownMenuBuilder(
              builder: (BuildContext context) {
                return new DropdownListMenu(
                  selectedIndex: 0,
                  data: actions,
                  itemBuilder: buildCheckItem,
                );
              },
              height: kDropdownMenuItemHeight * actions.length)
        ]);
  }

  DropdownHeader buildDropdownHeader({DropdownMenuHeadTapCallback onTap}) {
    return new DropdownHeader(
      onTap: onTap,
      titles: ['执行命令'],
    );
  }

  Widget buildFixHeaderDropdownMenu() {
    return new DefaultDropdownMenuController(
        onSelected: (
            {int menuIndex, int index, int subIndex, dynamic data}) async {
          String result = await _selecAndRun(data['id']);
          setState(() {
            Widget w = Container(
                height: 40,
                child: Align(
                    child: Text('$sn : ${DateTime.now()} ----',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    alignment: Alignment.centerLeft));
            String stdout = '命令：${data['title']}\n结果：$result';
            datasource.insert(
                0,
                Text(
                  stdout,
                  style: TextStyle(color: Colors.grey),
                ));
            datasource.insert(0, w);
            sn += 1;
          });
        },
        child: new Column(
          children: <Widget>[
            buildDropdownHeader(),
            new Expanded(
                child: new Stack(
              children: <Widget>[
                Padding(
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        return datasource[index];
                      },
                      itemCount: datasource.length,
                    ),
                    padding: EdgeInsets.fromLTRB(12, 12, 12, 12)),
                buildDropdownMenu()
              ],
            ))
          ],
        ));
  }

  GlobalKey globalKey;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: buildFixHeaderDropdownMenu(),
    );
  }
}
