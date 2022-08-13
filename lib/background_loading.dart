import 'package:flutter/material.dart';

class BackgroundLoading extends StatelessWidget {
  const BackgroundLoading(
      {Key? key, this.showSucces = false, this.title = 'Cargando'})
      : super(key: key);
  final bool showSucces;
  final String title;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.center,
      width: size.width,
      height: size.height,
      color: Colors.black.withOpacity(
        0.4,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: size.width * .4,
            height: size.height * .2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                15,
              ),
              color: Colors.black,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: showSucces
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 40,
                        )
                      : const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontFamily: 'NexaBold',
                    fontSize: 18,
                    letterSpacing: 5,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
