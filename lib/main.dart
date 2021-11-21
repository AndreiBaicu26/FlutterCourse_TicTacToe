import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.yellow,
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
  int currentPlayer = 0;
  int squaresPressed = 0;
  bool gameEnded = false;
  bool tieGame = false;

  // Generate List of Squares
  final List<List<Square>> _matrix = List<List<Square>>.generate(
      3,
      (int i) => List<Square>.generate(3, (int j) {
            return Square(i + j, -1);
          }, growable: false),
      growable: false);

  void setCurrentPlayer() {
    if (currentPlayer == 0) {
      currentPlayer = 1;
    } else {
      currentPlayer = 0;
    }
  }

  List<int> getIndexes(int position) {
    int count = 0;
    for (int j = 0; j < _matrix.length; j++) {
      for (int i = 0; i < _matrix[j].length; i++) {
        if (count == position) {
          return <int>[j, i];
        }
        count++;
      }
    }
    return <int>[0, 0];
  }

  bool checkVertical(int rowIndex, int columnIndex, Square pressedSquare) {
    bool won = true;
    for (int i = 0; i < 3; i++) {
      if (_matrix[i][columnIndex].currentPlayer != pressedSquare.currentPlayer) {
        won = false;
      }
    }
    return won;
  }

  bool checkHorizontal(int rowIndex, int columnIndex, Square pressedSquare) {
    bool won = true;
    for (int i = 0; i < 3; i++) {
      if (_matrix[rowIndex][i].currentPlayer != pressedSquare.currentPlayer) {
        won = false;
      }
    }
    return won;
  }

  bool checkMainDiagonal(int rowIndex, int columnIndex, Square pressedSquare) {
    bool won = true;
    for (int i = 0; i < 3; i++) {
      if (_matrix[i][i].currentPlayer != pressedSquare.currentPlayer) {
        won = false;
      }
    }
    return won;
  }

  bool checkSecondaryDiagonal(int rowIndex, int columnIndex, Square pressedSquare) {
    bool won = true;
    for (int i = 0; i < 3; i++) {
      if (_matrix[i][_matrix.length - 1 - i].currentPlayer != pressedSquare.currentPlayer) {
        won = false;
      }
    }
    return won;
  }

  bool cornerOfMatrixSelected(int columnIndex, int rowIndex) {
    return (columnIndex + rowIndex).isEven;
  }

  bool centerOfMatrixSelected(int columnIndex, int rowIndex) {
    return rowIndex == 1 && columnIndex == 1;
  }

  bool cornerOfMainDiagonal(int columnIndex, int rowIndex) {
    return rowIndex + columnIndex == 0 || rowIndex + columnIndex == _matrix.length + 1;
  }

  bool checkHorizontalAndVertical(int rowIndex, int columnIndex, Square pressedSquare) {
    return checkHorizontal(rowIndex, columnIndex, pressedSquare) || checkVertical(rowIndex, columnIndex, pressedSquare);
  }

  void processGameFinished(Square square) {
    setState(() {
      gameEnded = true;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (currentPlayer == _matrix[i][j].currentPlayer) {
            _matrix[i][j] = Square(square.index, -1);
          }
        }
      }
    });
  }

  void resetGame() {
    int index = 0;
    setState(() {
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          _matrix[i][j] = Square(index, -1);
          index++;
        }
      }
      squaresPressed = 0;
      gameEnded = false;
      tieGame = false;
    });
  }

  void checkIfPlayerWon(int rowIndex, int columnIndex, Square pressedSquare) {
    bool gameWon = false;
    squaresPressed++;
    if (centerOfMatrixSelected(columnIndex, rowIndex)) {
      //center of matrix
      if (checkHorizontalAndVertical(rowIndex, columnIndex, pressedSquare) ||
          checkMainDiagonal(rowIndex, columnIndex, pressedSquare) ||
          checkSecondaryDiagonal(rowIndex, columnIndex, pressedSquare)) {
        gameWon = true;
      }
    } else if (cornerOfMatrixSelected(columnIndex, rowIndex)) {
      //corners
      // check one diagonal + horizontal + verical
      if (cornerOfMainDiagonal(columnIndex, rowIndex)) {
        // on mainDiagonal
        if (checkHorizontalAndVertical(rowIndex, columnIndex, pressedSquare) ||
            checkMainDiagonal(rowIndex, columnIndex, pressedSquare)) {
          gameWon = true;
        }
      } else {
        // on secondary diag
        if (checkHorizontalAndVertical(rowIndex, columnIndex, pressedSquare) ||
            checkSecondaryDiagonal(rowIndex, columnIndex, pressedSquare)) {
          gameWon = true;
        }
      }
    } else {
      //check horizontal and vertical
      if (checkHorizontal(rowIndex, columnIndex, pressedSquare) ||
          checkVertical(rowIndex, columnIndex, pressedSquare)) {
        gameWon = true;
      }
    }

    if (gameWon) {
      processGameFinished(pressedSquare);
    }

    if (squaresPressed == 9 && gameWon == false) {
      setState(() {
        tieGame = true;
        gameEnded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('tic-tac-toe'),
      ),
      body: Column(
        children: <Widget>[
          GridView.builder(
            itemCount: 9,
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (BuildContext context, int index) {
              final List<int> matrixIndexes = getIndexes(index);
              final Square square = _matrix[matrixIndexes[0]][matrixIndexes[1]];

              return GestureDetector(
                onTap: () {
                  final List<int> matrixIndexes = getIndexes(index);
                  if (square.currentPlayer == -1) {
                    setState(() {
                      _matrix[matrixIndexes[0]][matrixIndexes[1]] = Square(square.index, currentPlayer);
                      setCurrentPlayer();
                    });

                    checkIfPlayerWon(matrixIndexes[0], matrixIndexes[1], _matrix[matrixIndexes[0]][matrixIndexes[1]]);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black45),
                      color: square.currentPlayer == -1
                          ? Colors.white
                          : (square.currentPlayer == 0 ? Colors.red : Colors.green)),
                ),
              );
            },
          ),
          Visibility(
            visible: gameEnded,
            child: ElevatedButton(
              onPressed: resetGame,
              child: const Text('Play again'),
            ),
          ),
          Visibility(
            visible: gameEnded && tieGame,
            child: const Text(
              "It's a tie",
              style: TextStyle(fontSize: 20),
            ),
          )
        ],
      ),
    );
  }
}

class MatrixIndexes {
  MatrixIndexes(this.rowIndex, this.columnIndex);

  final int rowIndex;
  final int columnIndex;
}

class Square {
  const Square(this.index, this.currentPlayer);

  final int index;
  final int currentPlayer;
}
