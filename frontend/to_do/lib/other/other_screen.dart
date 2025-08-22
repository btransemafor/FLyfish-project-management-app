import 'package:flutter/material.dart';
import 'package:to_do/features/projects/presentation/widgets/avatar_circle.dart';

List<String> avatar = [
  'https://res.cloudinary.com/dehehzz2t/image/upload/v1747655025/images_2_oaj1sh.jpg',
  'https://res.cloudinary.com/dehehzz2t/image/upload/v1752052040/anh-dai-dien-hai-yodyvn1_utt8c5.jpg',
  'https://res.cloudinary.com/dehehzz2t/image/upload/v1752048876/mbapple_b6z0p4.jpg',
  'https://res.cloudinary.com/dehehzz2t/image/upload/v1747659085/a4c0865c89c3566234a9efd5a0886d2a_ezvrpk.jpg',
  'https://res.cloudinary.com/dehehzz2t/image/upload/v1742999329/cld-sample.jpg'
];

class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < avatar.length; i++)
                Transform.translate(
                  offset: Offset(-3 * i * 8.0, 0), // avatar chồng lên
                  child: AvatarCircle(avatar: avatar[i], size: 30),
                ),
            ],
          ),
          SizedBox(
            height: 50,
            width: 200,
            child: Stack(children: [
              for (int i = 0; i < avatar.length; i++)
                Positioned(
                    left: i * 20 - 4,
                    child: AvatarCircle(avatar: avatar[i], size: 20))
            ]),
          ),
/*           Transform.translate(
            offset: const Offset(0.0, 15.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: const Color(0xFF7F7F7F),
              child: const Text('Quarter'),
            ),
          ),

          // Skewing
Transform(
              transform: Matrix4.skew(-0.5, 0.1), // Apply horizontal skew
              child: Container(
                width: 100,
                height: 100,
                color: Colors.orange, // Orange container
                child: Center(
                  child: Text(
                    'Skewing', // Text label
                    style: TextStyle(
                      color: Colors.white, // Text color
                      fontWeight: FontWeight.bold, // Bold text
                    ),
                  ),
                ),
              ),
            ),

            Transform.rotate(angle: 0.747, child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(shape: BoxShape.rectangle,
              color: Colors.amber
              ),
            ),), 
 */

          const SizedBox(
            height: 50,
          ),
          Row(
            children: [
              for (var i = 0; i < avatar.length; i++)
                Transform.translate(
                  offset: Offset(-2*i * 4, 10.0),
                  child: _buildSquareAvatar(avatar[i]),
                )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSquareAvatar(String avatar) {
    return Transform.rotate(
      angle: 0.523,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(4),
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(),
          child: Image.network(
            avatar,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
