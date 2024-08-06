import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soundofmeme/screens/sign_up_screen.dart';
import 'package:soundofmeme/widgets/customTextFormField.dart';
import 'package:soundofmeme/widgets/customButton.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController songController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController lyricsController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final storage = const FlutterSecureStorage();
  String? token;
  bool _isLoading = false;
  bool _isAllsongsLoading = false;
  bool _isCustomLoading = false;
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, dynamic> res = {};
  Map<String, dynamic> customRes = {};
  List<Map<String, dynamic>> _songs = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    getToken();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    titleController.dispose();
    genreController.dispose();
    lyricsController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.index == 2) {
      _fetchAllSongs(1);
    }
  }

  Future<void> getToken() async {
    token = await storage.read(key: 'access_token');
  }

  Future<Map<String, dynamic>> createSong() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('http://143.244.131.156:8000/create'),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({"song": songController.text}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
        jsonDecode(response.body);
        return responseData;
      } else {
        return {'error': 'Failed to create a song'};
      }
    } catch (e) {
      return {'error': e.toString()};
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> createCustomSong() async {
    setState(() {
      _isCustomLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('http://143.244.131.156:8000/createcustom'),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "title": titleController.text,
          "lyric": lyricsController.text,
          "genere": genreController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        return {'error': 'Failed to create a custom song'};
      }
    } catch (e) {
      return {'error': e.toString()};
    } finally {
      setState(() {
        _isCustomLoading = false;
      });
    }
  }

  Future<void> _fetchAllSongs(int page) async {
    setState(() {
      _isAllsongsLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('http://143.244.131.156:8000/allsongs?page=$page'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Assuming the key 'songs' contains the list of songs
        final List<dynamic> songsList = responseData['songs'] ?? [];
        setState(() {
          _songs =
              songsList.map((song) => song as Map<String, dynamic>).toList();
        });
      } else {
        debugPrint('Failed to fetch songs: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching songs: $e');
    } finally {
      setState(() {
        _isAllsongsLoading = false;
      });
    }
  }


  void _playPause(String songUrl) async {
    if (_isPlaying) {
      await _audioPlayer.stop();
    } else {
      await _audioPlayer.setSourceUrl(songUrl);
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff1A1D21),
          centerTitle: true,
          title: const Text("Sound of Meme",style: TextStyle(color: Colors.white),),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: "Create"),
              Tab(text: "Custom"),
              Tab(text: "All Songs"),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0, top: 8),
              child: IconButton(
                onPressed: () {
                  storage.deleteAll();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white70,
                ),
              ),
            )
          ],
        ),
        backgroundColor: const Color(0xff1A1D21),
        body: TabBarView(
          controller: _tabController,
          children: [
            SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: mediaQuery.size.width * 0.04,
                    vertical: mediaQuery.size.height * 0.2,
                  ),
                  child: Column(
                    children: [
                      CustomTextFormField(
                        controller: songController,
                        hintText: "Enter song details you want to create...!",
                      ),
                      SizedBox(height: mediaQuery.size.height * 0.1),
                      CustomButton(
                        btnText: "Create",
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          if (await storage.containsKey(key: 'access_token')) {
                            res = await createSong();
                            if (kDebugMode) {
                              print(res);
                            }
                            setState(() {}); // Update UI with new data
                          }
                        },
                      ),
                      SizedBox(height: mediaQuery.size.height * 0.06),
                      if (_isLoading)
                        const CircularProgressIndicator(),
                      if (res.isNotEmpty && !_isLoading)
                        SizedBox(
                          height: mediaQuery.size.height * 0.15,
                          child: Card(
                            elevation: 6,
                            color: const Color(0x401a1d21),
                            child: Row(
                              children: [
                                const SizedBox(width: 5),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: SizedBox.fromSize(
                                    size: Size.fromRadius(
                                        mediaQuery.size.width * 0.119),
                                    child: Image.network(
                                      res['image_url'] ?? '',
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.broken_image,
                                              size: mediaQuery.size.width * 0.1),
                                    ),
                                  ),
                                ),
                                SizedBox(width: mediaQuery.size.width * 0.04),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 15),
                                      Text(
                                        res['song_name'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.white70),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.favorite, color: Colors.red),
                                          SizedBox(width: mediaQuery.size.width * 0.01),
                                          Text(
                                            res['likes'].toString(),
                                            style: const TextStyle(color: Colors.white70),
                                          ),
                                          SizedBox(width: mediaQuery.size.width * 0.08),
                                          const Icon(Icons.remove_red_eye, color: Colors.grey),
                                          SizedBox(width: mediaQuery.size.width * 0.01),
                                          Text(
                                            res['views'].toString(),
                                            style: const TextStyle(color: Colors.white70),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Flexible(
                                        child: Text(
                                          res['tags']?.join(', ') ?? '',
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                      // SizedBox(height: mediaQuery.size.height * 0.03),

                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: const CircleBorder(),minimumSize: const Size(50, 60),
                                      backgroundColor: _isPlaying
                                          ? Colors.red
                                          : Colors.blue,
                                    ),
                                    onPressed: () => _playPause(res['song_url'] ?? ''),
                                    child: const Icon(Icons.play_arrow),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: mediaQuery.size.width * 0.04,
                    vertical: mediaQuery.size.height * 0.1,
                  ),
                  child: Column(
                    children: [
                      CustomTextFormField(
                        controller: titleController,
                        hintText: "Enter title of the song",
                      ),
                      SizedBox(height: mediaQuery.size.height * 0.02),
                      CustomTextFormField(
                        controller: lyricsController,
                        hintText: "Enter lyrics of the song",
                      ),
                      SizedBox(height: mediaQuery.size.height * 0.02),
                      CustomTextFormField(
                        controller: genreController,
                        hintText: "Enter genre of the song",
                      ),
                      SizedBox(height: mediaQuery.size.height * 0.1),
                      CustomButton(
                        btnText: "Create Custom",
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          if (await storage.containsKey(key: 'access_token')) {
                            customRes = await createCustomSong();
                            if (kDebugMode) {
                              print(customRes);
                            }
                            setState(() {});
                          }
                        },
                      ),
                      SizedBox(height: mediaQuery.size.height * 0.06),
                      if (_isCustomLoading)
                        const CircularProgressIndicator(),
                      if (customRes.isNotEmpty && !_isCustomLoading)
                        SizedBox(
                          height: mediaQuery.size.height * 0.15,
                          child: Card(
                            elevation: 6,
                            color: const Color(0x401a1d21),
                            child: Row(
                              children: [
                                const SizedBox(width: 5),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: SizedBox.fromSize(
                                    size: Size.fromRadius(
                                        mediaQuery.size.width * 0.119),
                                    child: Image.network(
                                      customRes['image_url'] ?? '',
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.broken_image,
                                              size: mediaQuery.size.width * 0.1),
                                    ),
                                  ),
                                ),
                                SizedBox(width: mediaQuery.size.width * 0.04),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 15),
                                      Text(
                                        customRes['song_name'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.white70),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.favorite, color: Colors.red),
                                          SizedBox(width: mediaQuery.size.width * 0.01),
                                          Text(
                                            customRes['likes'].toString(),
                                            style: const TextStyle(color: Colors.white70),
                                          ),
                                          SizedBox(width: mediaQuery.size.width * 0.08),
                                          const Icon(Icons.remove_red_eye, color: Colors.grey),
                                          SizedBox(width: mediaQuery.size.width * 0.01),
                                          Text(
                                            customRes['views'].toString(),
                                            style: const TextStyle(color: Colors.white70),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Flexible(
                                        child: Text(
                                          customRes['tags']?.join(', ') ?? '',
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: const CircleBorder(),minimumSize: const Size(50, 60),
                                      backgroundColor: _isPlaying
                                          ? Colors.red
                                          : Colors.blue,
                                    ),
                                    onPressed: () => _playPause(res['song_url'] ?? ''),
                                    child: const Icon(Icons.play_arrow),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: mediaQuery.size.width * 0.02,
                    vertical: mediaQuery.size.height * 0.02,
                  ),
                  child: Column(
                    children: [
                      if (_isAllsongsLoading)
                        const CircularProgressIndicator(),
                      if (!_isAllsongsLoading && _songs.isEmpty)
                        const Text(
                          'No songs available',
                          style: TextStyle(color: Colors.white70),
                        ),
                      if (!_isAllsongsLoading && _songs.isNotEmpty)
                        SizedBox(
                          height: mediaQuery.size.height * 0.8,
                          child: ListView.builder(
                            itemCount: _songs.length,
                            itemBuilder: (context, index) {
                              final song = _songs[index];
                              return ListTile(
                                title: Text(
                                  song['song_name'] ?? 'Unknown Song',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                subtitle: Text(
                                  song['tags']?.join(', ') ?? 'No Tags',
                                  style: const TextStyle(color: Colors.white54),
                                ),
                                leading: Image.network(
                                  song['image_url'] ?? 'https://via.placeholder.com/150',
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.broken_image, size: mediaQuery.size.width * 0.1),
                                ),
                                onTap: () => _playPause(song['song_url'] ?? ''),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
