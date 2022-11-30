import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

const bombIndexes = [2, 22, 41, 42, 52, 63, 64, 72, 77];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final List<int> selectedIndexes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          padding: const EdgeInsets.all(10),
          itemCount: 9 * 9,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: (() {
                setState(() {
                  if(!selectedIndexes.contains(index)) {
                    selectedIndexes.add(index);
                  }
                  if(getNumberOfBombsArround(index) == 0) {
                    selectedIndexes.addAll(getEmptySurrounds(index));
                  }
                });
                if(bombIndexes.contains(index)) {
                  showAlert(context, false);
                } else {
                  if(selectedIndexes.length + bombIndexes.length == 81) {
                    showAlert(context, true);
                  }
                }
              }),
              child: MinesweeperTile(index, selectedIndexes.contains(index))
            );
          },
        ),
      )
    );
  }

  List<int> getEmptySurrounds(int index) {
    List<int> surrounds = getIndexesAround(index);
    surrounds.removeWhere((surround) => selectedIndexes.contains(surround) || (surround > 80) || (surround < 0));
    return surrounds;
  }

  Future<void> showAlert(BuildContext context, bool hasWin) { 
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: hasWin ? const Text('CONGRATS') : const Text('GAME OVER'),
          content: hasWin ? const Text('You win !') : const Text('You loose !'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Start new game'),
              onPressed: () {
                setState(() {
                  selectedIndexes.clear();
                  Navigator.of(context).pop();
                });
              },
            )]
        );
      },
    );
  }
}

// ignore: must_be_immutable
class MinesweeperTile extends StatelessWidget {

  final int index;
  final bool isSelected;
  bool hasBombsAround = false;
  bool showText = false;
  
  MinesweeperTile(this.index, this.isSelected, {Key? key}) : super(key: key) {
    hasBombsAround = calculateBombs() > 0;
    showText = hasBombsAround && isSelected;
  }
  
  int calculateBombs() {
    return getNumberOfBombsArround(index);
  }

  @override
  Widget build(BuildContext context) {
    var printColor = Colors.grey;
    if(isSelected) {
      if(bombIndexes.contains(index)) {
        printColor = Colors.red;
      } else {
        printColor = Colors.blueGrey;
      }
    }
    return ColoredBox(
      color: printColor,
      child: showText ? Center(
        child: Text(
          calculateBombs().toString(),
          textAlign: TextAlign.center,
        ),
      ) : null
    );
  }
}

int getNumberOfBombsArround(index) {
  int countBombs = 0;
  List<int> surrounds = getIndexesAround(index);
  for(int i in surrounds) {
    if(bombIndexes.contains(i)) {
      countBombs += 1;
    }
  }
  return countBombs;
}

List<int> getIndexesAround(index) {
  List<int> surrounds = [index-1, index+1, index-10, index-9, index-8, index+8, index+9, index+10];
  if(index % 9 == 0) {
    surrounds = [index+1, index-9, index-8, index+9, index+10];
  } else if(index % 9 == 8) {
    surrounds = [index-1, index-10, index-9, index+8, index+9];
  }
  return surrounds;
}
