import 'package:flutter/material.dart';
import 'package:arabic_learning_app/constants.dart';
import 'dart:math';

// Function to remove tashkeel (diacritics) from Arabic text
String removeTashkeel(String text) {
  return text.replaceAll(RegExp(r'[ً-ٟ]'), '');
}

class GridCell {
  String letter;
  final int row;
  final int col;
  bool isPartOfWord;
  bool isSelected;
  bool isFound;

  GridCell({
    required this.letter,
    required this.row,
    required this.col,
    this.isPartOfWord = false,
    this.isSelected = false,
    this.isFound = false,
  });
}

class WordToFind {
  final String word;
  final String emoji;
  final List<GridCell> cells;
  bool isFound;

  WordToFind({
    required this.word,
    required this.emoji,
    required this.cells,
    this.isFound = false,
  });
}

class WordSearchViewBody extends StatefulWidget {
  const WordSearchViewBody({super.key});

  @override
  State<WordSearchViewBody> createState() => _WordSearchViewBodyState();
}

class _WordSearchViewBodyState extends State<WordSearchViewBody> {
  static const int gridSize = 10;
  List<List<GridCell>> grid = [];
  List<WordToFind> wordsToFind = [];
  List<GridCell> currentSelection = [];
  int foundWords = 0;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    grid.clear();
    wordsToFind.clear();
    currentSelection.clear();
    foundWords = 0;
    isDragging = false;

    // Initialize empty grid
    for (int i = 0; i < gridSize; i++) {
      grid.add([]);
      for (int j = 0; j < gridSize; j++) {
        grid[i].add(GridCell(letter: '', row: i, col: j));
      }
    }

    // Select random words
    final random = Random();
    final selectedIndices = <int>[];
    while (selectedIndices.length < 5) {
      final index = random.nextInt(arabicLetters.length);
      if (!selectedIndices.contains(index)) {
        final word = arabicLetters[index].word;
        // Only select words that fit in the grid
        if (word.length <= gridSize) {
          selectedIndices.add(index);
        }
      }
    }

    // Place words in grid
    for (final index in selectedIndices) {
      final letterData = arabicLetters[index];
      final wordWithoutTashkeel = removeTashkeel(letterData.word);
      _placeWord(wordWithoutTashkeel, letterData.emoji);
    }

    // Fill empty cells with random letters
    _fillEmptyCells();

    setState(() {});
  }

  void _placeWord(String word, String emoji) {
    final random = Random();
    final wordChars = word.split('');
    bool placed = false;
    int attempts = 0;
    const maxAttempts = 100;

    while (!placed && attempts < maxAttempts) {
      attempts++;
      // Random direction: 0 = horizontal, 1 = vertical, 2 = diagonal down-right, 3 = diagonal down-left
      final direction = random.nextInt(4);

      if (direction == 0) {
        // Horizontal
        final row = random.nextInt(gridSize);
        final col = random.nextInt(gridSize - wordChars.length + 1);

        if (_canPlaceHorizontal(row, col, wordChars)) {
          final cells = <GridCell>[];
          for (int i = 0; i < wordChars.length; i++) {
            grid[row][col + i].letter = wordChars[i];
            grid[row][col + i].isPartOfWord = true;
            cells.add(grid[row][col + i]);
          }
          wordsToFind.add(WordToFind(word: word, emoji: emoji, cells: cells));
          placed = true;
        }
      } else if (direction == 1) {
        // Vertical
        final row = random.nextInt(gridSize - wordChars.length + 1);
        final col = random.nextInt(gridSize);

        if (_canPlaceVertical(row, col, wordChars)) {
          final cells = <GridCell>[];
          for (int i = 0; i < wordChars.length; i++) {
            grid[row + i][col].letter = wordChars[i];
            grid[row + i][col].isPartOfWord = true;
            cells.add(grid[row + i][col]);
          }
          wordsToFind.add(WordToFind(word: word, emoji: emoji, cells: cells));
          placed = true;
        }
      } else if (direction == 2) {
        // Diagonal down-right
        final row = random.nextInt(gridSize - wordChars.length + 1);
        final col = random.nextInt(gridSize - wordChars.length + 1);

        if (_canPlaceDiagonalDownRight(row, col, wordChars)) {
          final cells = <GridCell>[];
          for (int i = 0; i < wordChars.length; i++) {
            grid[row + i][col + i].letter = wordChars[i];
            grid[row + i][col + i].isPartOfWord = true;
            cells.add(grid[row + i][col + i]);
          }
          wordsToFind.add(WordToFind(word: word, emoji: emoji, cells: cells));
          placed = true;
        }
      } else {
        // Diagonal down-left
        final row = random.nextInt(gridSize - wordChars.length + 1);
        final col = wordChars.length + random.nextInt(gridSize - wordChars.length);

        if (_canPlaceDiagonalDownLeft(row, col, wordChars)) {
          final cells = <GridCell>[];
          for (int i = 0; i < wordChars.length; i++) {
            grid[row + i][col - i].letter = wordChars[i];
            grid[row + i][col - i].isPartOfWord = true;
            cells.add(grid[row + i][col - i]);
          }
          wordsToFind.add(WordToFind(word: word, emoji: emoji, cells: cells));
          placed = true;
        }
      }
    }
  }

  bool _canPlaceHorizontal(int row, int col, List<String> wordChars) {
    for (int i = 0; i < wordChars.length; i++) {
      if (grid[row][col + i].letter.isNotEmpty &&
          grid[row][col + i].letter != wordChars[i]) {
        return false;
      }
    }
    return true;
  }

  bool _canPlaceVertical(int row, int col, List<String> wordChars) {
    for (int i = 0; i < wordChars.length; i++) {
      if (grid[row + i][col].letter.isNotEmpty &&
          grid[row + i][col].letter != wordChars[i]) {
        return false;
      }
    }
    return true;
  }

  bool _canPlaceDiagonalDownRight(int row, int col, List<String> wordChars) {
    for (int i = 0; i < wordChars.length; i++) {
      if (grid[row + i][col + i].letter.isNotEmpty &&
          grid[row + i][col + i].letter != wordChars[i]) {
        return false;
      }
    }
    return true;
  }

  bool _canPlaceDiagonalDownLeft(int row, int col, List<String> wordChars) {
    for (int i = 0; i < wordChars.length; i++) {
      if (grid[row + i][col - i].letter.isNotEmpty &&
          grid[row + i][col - i].letter != wordChars[i]) {
        return false;
      }
    }
    return true;
  }

  void _fillEmptyCells() {
    final random = Random();
    final arabicChars = letters;

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j].letter.isEmpty) {
          grid[i][j].letter = arabicChars[random.nextInt(arabicChars.length)];
        }
      }
    }
  }

  void _onCellDragStart(GridCell cell) {
    setState(() {
      isDragging = true;
      currentSelection.clear();
      currentSelection.add(cell);
      cell.isSelected = true;
    });
  }

  void _onCellDragUpdate(GridCell cell) {
    if (!isDragging) return;

    if (!currentSelection.contains(cell)) {
      // Check if cell is adjacent to last selected cell
      if (currentSelection.isNotEmpty) {
        final lastCell = currentSelection.last;
        final isAdjacent = _isAdjacent(lastCell, cell);

        if (isAdjacent) {
          setState(() {
            currentSelection.add(cell);
            cell.isSelected = true;
          });
        }
      }
    }
  }

  bool _isAdjacent(GridCell cell1, GridCell cell2) {
    final rowDiff = (cell1.row - cell2.row).abs();
    final colDiff = (cell1.col - cell2.col).abs();
    
    // Check if cells are adjacent (horizontal, vertical, or diagonal)
    return rowDiff <= 1 && colDiff <= 1 && (rowDiff + colDiff) > 0;
  }

  void _onCellDragEnd() {
    if (!isDragging) return;

    setState(() {
      isDragging = false;
      _checkSelection();
      
      // Clear selection
      for (final cell in currentSelection) {
        cell.isSelected = false;
      }
      currentSelection.clear();
    });
  }

  void _checkSelection() {
    if (currentSelection.length < 2) return;

    final selectedWord = currentSelection.map((c) => c.letter).join('');

    for (final wordToFind in wordsToFind) {
      if (wordToFind.isFound) continue;

      // Check if selection matches the word
      if (selectedWord == wordToFind.word ||
          selectedWord == wordToFind.word.split('').reversed.join('')) {
        // Check if cells match
        if (_cellsMatch(currentSelection, wordToFind.cells)) {
          setState(() {
            wordToFind.isFound = true;
            foundWords++;
            for (final cell in wordToFind.cells) {
              cell.isFound = true;
            }

            if (foundWords == wordsToFind.length) {
              _showWinDialog();
            }
          });
          return;
        }
      }
    }
  }

  bool _cellsMatch(List<GridCell> selection, List<GridCell> wordCells) {
    if (selection.length != wordCells.length) return false;

    // Check forward
    bool forwardMatch = true;
    for (int i = 0; i < selection.length; i++) {
      if (selection[i] != wordCells[i]) {
        forwardMatch = false;
        break;
      }
    }
    if (forwardMatch) return true;

    // Check backward
    bool backwardMatch = true;
    for (int i = 0; i < selection.length; i++) {
      if (selection[i] != wordCells[wordCells.length - 1 - i]) {
        backwardMatch = false;
        break;
      }
    }
    return backwardMatch;
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎉', style: TextStyle(fontSize: 30)),
            SizedBox(width: 8),
            Text('رائع!', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Text('🎉', style: TextStyle(fontSize: 30)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'لقد وجدت جميع الكلمات!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
                  const SizedBox(width: 8),
                  Text(
                    'الكلمات: $foundWords / ${wordsToFind.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeGame();
            },
            child: const Text(
              'لعب مرة أخرى',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.orange.shade50, Colors.yellow.shade50],
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🔍', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'البحث عن الكلمات',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('🔍', style: TextStyle(fontSize: 24)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search, color: Colors.orange, size: 20),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'المكتشفة: $foundWords / ${wordsToFind.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Words to find
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: wordsToFind.length,
              itemBuilder: (context, index) {
                final word = wordsToFind[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: word.isFound ? Colors.green.shade100 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: word.isFound ? Colors.green : Colors.orange.shade200,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        word.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                      if (word.isFound)
                        const Icon(Icons.check_circle, color: Colors.green, size: 14),
                    ],
                  ),
                );
              },
            ),
          ),

          // Grid
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cellSize = constraints.maxWidth / gridSize;
                      return GestureDetector(
                        onPanStart: (details) {
                          final cell = _getCellFromPosition(details.localPosition, cellSize);
                          if (cell != null) {
                            _onCellDragStart(cell);
                          }
                        },
                        onPanUpdate: (details) {
                          final cell = _getCellFromPosition(details.localPosition, cellSize);
                          if (cell != null) {
                            _onCellDragUpdate(cell);
                          }
                        },
                        onPanEnd: (details) {
                          _onCellDragEnd();
                        },
                        child: Stack(
                          children: [
                            // Grid
                            Column(
                              children: List.generate(
                                gridSize,
                                (row) => Row(
                                  children: List.generate(
                                    gridSize,
                                    (col) => _buildCell(grid[row][col], cellSize),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Reset Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _initializeGame();
                });
              },
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text(
                'لعبة جديدة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  GridCell? _getCellFromPosition(Offset position, double cellSize) {
    final row = (position.dy / cellSize).floor();
    final col = (position.dx / cellSize).floor();

    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      return grid[row][col];
    }
    return null;
  }

  Widget _buildCell(GridCell cell, double size) {
    Color backgroundColor;
    if (cell.isFound) {
      backgroundColor = Colors.green.shade200;
    } else if (cell.isSelected) {
      backgroundColor = Colors.orange.shade300;
    } else {
      backgroundColor = Colors.white;
    }

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: cell.isFound
              ? Colors.green
              : cell.isSelected
                  ? Colors.orange
                  : Colors.grey.shade300,
          width: cell.isFound || cell.isSelected ? 2 : 1,
        ),
      ),
      child: Center(
        child: Text(
          cell.letter,
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: cell.isFound
                ? Colors.green.shade900
                : cell.isSelected
                    ? Colors.orange.shade900
                    : Colors.black87,
          ),
        ),
      ),
    );
  }
}
