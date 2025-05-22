import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/user_service.dart';
import '../utils/api_config.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<User> _leaderboardUsers = [];
  bool _isLoading = true;
  String? _errorMessage;
  final UserService _userService = UserService();

  // Batik Nusantara Color Palette
  final Color primaryBrown = const Color(0xFF8B4513);
  final Color secondaryGold = const Color(0xFFDAA520);
  final Color accentMaroon = const Color(0xFF800020);
  final Color deepBrown = const Color(0xFF5D2E0C);
  final Color lightCream = const Color(0xFFF5F5DC);
  final Color earthyOrange = const Color(0xFFCD853F);

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getFullUrl('/leaderboard')),
        headers: ApiConfig.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> usersJson = data['data']['leaderboard'];
          setState(() {
            _leaderboardUsers = usersJson.map((userJson) => User(
                username: userJson['username'],
                avatar: userJson['avatar'] ?? 'assets/avatars/default.png',
                level: userJson['level'] ?? 1,
                score: userJson['score'] ?? 0,
              )).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to load leaderboard';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    IconData badgeIcon;
    
    switch (rank) {
      case 1:
        badgeColor = secondaryGold;
        badgeIcon = Icons.star;
        break;
      case 2:
        badgeColor = const Color(0xFFC0C0C0);
        badgeIcon = Icons.star;
        break;
      case 3:
        badgeColor = const Color(0xFFCD7F32);
        badgeIcon = Icons.star;
        break;
      default:
        badgeColor = primaryBrown.withOpacity(0.3);
        badgeIcon = Icons.person;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        border: Border.all(color: deepBrown, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: rank <= 3
          ? Icon(
              badgeIcon,
              color: Colors.white,
              size: 24,
            )
          : Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: deepBrown,
                  fontSize: 16,
                ),
              ),
            ),
    );
  }

  Widget _buildUserAvatar(String avatarPath) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: secondaryGold, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 25,
        backgroundColor: lightCream,
        child: ClipOval(
          child: avatarPath.isNotEmpty
              ? (avatarPath.startsWith('http')
                  ? Image.network(
                      avatarPath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, size: 30, color: primaryBrown);
                      },
                    )
                  : Image.asset(
                      avatarPath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, size: 30, color: primaryBrown);
                      },
                    ))
              : Icon(Icons.person, size: 30, color: primaryBrown),
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(User user, int rank, bool isLandscape) {
    final isCurrentUser = _userService.currentUser?.username == user.username;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isLandscape ? 8 : 16, 
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCurrentUser 
              ? [lightCream, secondaryGold.withOpacity(0.2)]
              : [Colors.white, lightCream.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser 
            ? Border.all(color: secondaryGold, width: 2)
            : Border.all(color: primaryBrown.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isLandscape ? 12 : 16, 
          vertical: isLandscape ? 4 : 8,
        ),
        leading: _buildRankBadge(rank),
        title: Row(
          children: [
            _buildUserAvatar(user.avatar),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isLandscape ? 14 : 16,
                      color: isCurrentUser ? accentMaroon : deepBrown,
                    ),
                  ),
                  Text(
                    'Level ${user.level}',
                    style: TextStyle(
                      color: primaryBrown.withOpacity(0.7),
                      fontSize: isLandscape ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 8 : 12, 
            vertical: isLandscape ? 4 : 6,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: rank <= 3 
                  ? [secondaryGold.withOpacity(0.3), secondaryGold.withOpacity(0.1)]
                  : [primaryBrown.withOpacity(0.2), primaryBrown.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: rank <= 3 ? secondaryGold : primaryBrown.withOpacity(0.3),
            ),
          ),
          child: Text(
            '${user.score} pts',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: rank <= 3 ? accentMaroon : deepBrown,
              fontSize: isLandscape ? 12 : 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopThree(bool isLandscape) {
    if (_leaderboardUsers.length < 3) return Container();
    
    return Container(
      padding: EdgeInsets.all(isLandscape ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryBrown,
            deepBrown,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPodiumPosition(_leaderboardUsers[1], 2, isLandscape ? 60 : 80, isLandscape),
          _buildPodiumPosition(_leaderboardUsers[0], 1, isLandscape ? 80 : 100, isLandscape),
          _buildPodiumPosition(_leaderboardUsers[2], 3, isLandscape ? 40 : 60, isLandscape),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(User user, int rank, double height, bool isLandscape) {
    Color podiumColor;
    double topMargin;
    
    switch (rank) {
      case 1:
        podiumColor = secondaryGold;
        topMargin = 0;
        break;
      case 2:
        podiumColor = const Color(0xFFC0C0C0);
        topMargin = isLandscape ? 20 : 30;
        break;
      case 3:
        podiumColor = const Color(0xFFCD7F32);
        topMargin = isLandscape ? 40 : 60;
        break;
      default:
        podiumColor = primaryBrown.withOpacity(0.3);
        topMargin = 0;
    }

    return Column(
      children: [
        SizedBox(height: topMargin),
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: EdgeInsets.only(top: isLandscape ? 15 : 20),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: lightCream, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: isLandscape ? 20 : 25,
                  backgroundColor: lightCream,
                  child: ClipOval(
                    child: user.avatar.isNotEmpty
                        ? (user.avatar.startsWith('http')
                            ? Image.network(
                                user.avatar,
                                width: isLandscape ? 40 : 50,
                                height: isLandscape ? 40 : 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.person, 
                                    size: isLandscape ? 25 : 30, 
                                    color: primaryBrown);
                                },
                              )
                            : Image.asset(
                                user.avatar,
                                width: isLandscape ? 40 : 50,
                                height: isLandscape ? 40 : 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.person, 
                                    size: isLandscape ? 25 : 30, 
                                    color: primaryBrown);
                                },
                              ))
                        : Icon(Icons.person, 
                            size: isLandscape ? 25 : 30, 
                            color: primaryBrown),
                  ),
                ),
              ),
            ),
            Container(
              width: isLandscape ? 25 : 30,
              height: isLandscape ? 25 : 30,
              decoration: BoxDecoration(
                color: podiumColor,
                shape: BoxShape.circle,
                border: Border.all(color: lightCream, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isLandscape ? 12 : 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isLandscape ? 6 : 8),
        SizedBox(
          width: isLandscape ? 80 : 100,
          child: Text(
            user.username,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isLandscape ? 10 : 12,
              color: lightCream,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: isLandscape ? 2 : 4),
        Text(
          '${user.score} pts',
          style: TextStyle(
            color: lightCream.withOpacity(0.8),
            fontSize: isLandscape ? 9 : 11,
          ),
        ),
        SizedBox(height: isLandscape ? 6 : 8),
        Container(
          width: isLandscape ? 50 : 60,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                podiumColor,
                podiumColor.withOpacity(0.8),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: lightCream.withOpacity(0.3)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Papan Peringkat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: lightCream,
                fontSize: isLandscape ? 18 : 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: primaryBrown,
            foregroundColor: lightCream,
            elevation: 4,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryBrown, deepBrown],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: lightCream),
                onPressed: _fetchLeaderboard,
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lightCream,
                  Colors.white,
                ],
              ),
            ),
            child: RefreshIndicator(
              onRefresh: _fetchLeaderboard,
              color: primaryBrown,
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryBrown),
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: isLandscape ? 48 : 64,
                                color: primaryBrown.withOpacity(0.5),
                              ),
                              SizedBox(height: isLandscape ? 12 : 16),
                              Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: deepBrown,
                                  fontSize: isLandscape ? 14 : 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: isLandscape ? 12 : 16),
                              ElevatedButton(
                                onPressed: _fetchLeaderboard,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBrown,
                                  foregroundColor: lightCream,
                                ),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      : _leaderboardUsers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.emoji_events_outlined,
                                    size: isLandscape ? 48 : 64,
                                    color: primaryBrown.withOpacity(0.5),
                                  ),
                                  SizedBox(height: isLandscape ? 12 : 16),
                                  Text(
                                    'Belum ada pengguna',
                                    style: TextStyle(
                                      color: deepBrown,
                                      fontSize: isLandscape ? 14 : 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : isLandscape
                              ? Row(
                                  children: [
                                    // Top 3 section untuk landscape
                                    if (_leaderboardUsers.length >= 3)
                                      Expanded(
                                        flex: 2,
                                        child: _buildTopThree(isLandscape),
                                      ),
                                    // Leaderboard list untuk landscape
                                    Expanded(
                                      flex: 3,
                                      child: ListView.builder(
                                        padding: const EdgeInsets.all(8),
                                        itemCount: _leaderboardUsers.length,
                                        itemBuilder: (context, index) {
                                          final user = _leaderboardUsers[index];
                                          final rank = index + 1;
                                          return _buildLeaderboardItem(user, rank, isLandscape);
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    // Top 3 podium untuk portrait
                                    if (_leaderboardUsers.length >= 3) ...[
                                      _buildTopThree(isLandscape),
                                      const SizedBox(height: 20),
                                    ],
                                    
                                    // Full leaderboard list untuk portrait
                                    Expanded(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.only(bottom: 20),
                                        itemCount: _leaderboardUsers.length,
                                        itemBuilder: (context, index) {
                                          final user = _leaderboardUsers[index];
                                          final rank = index + 1;
                                          return _buildLeaderboardItem(user, rank, isLandscape);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
            ),
          ),
        );
      },
    );
  }
}