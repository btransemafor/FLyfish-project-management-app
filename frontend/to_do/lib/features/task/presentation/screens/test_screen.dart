import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do/features/attachments/presentation/bloc/attachment_bloc.dart';
import 'package:to_do/features/attachments/presentation/bloc/attachment_event.dart';
import 'package:to_do/features/attachments/presentation/bloc/attachment_state.dart';
import 'package:to_do/features/task/presentation/bloc/task_event.dart';
import 'package:to_do/features/task/presentation/screens/task_detail_screen.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  void initState() {
    super.initState();
    // Gửi event khi màn hình được load
    context.read<AttachmentBloc>().add(
      FetchTaskFiles(taskId: 'fa6c8bff-a350-4864-b752-4eac8c0968af')
    );
  }

  @override
  Widget build(BuildContext context) {
    return 
      Scaffold(
        appBar: AppBar(
          title: const Text('Task Detail'),
        ),
        body: BlocBuilder<AttachmentBloc, AttachmentState>(
          builder: (context, state) {
            if (state is AttachmentLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AttachmentFetchSuccess) {
              final files = state.files; // object task từ API
      
                return ListView.builder(
                  itemCount: files.length,
                  
                  itemBuilder: (context, index) {
                  final file = files[index]; 
                  return ListTile(title: Text(file.fileName),);
                }); 
            } else if (state is AttachmentError) {
              return Center(child: Text('Error: ${state.error}'));
            }
            return const SizedBox.shrink();
          },
        ),
      );
    
  }
}



// Cách 2: Custom Route với nhiều tùy chọn hơn
class CustomSlideRoute<T> extends MaterialPageRoute<T> {
  CustomSlideRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Slide từ phải sang trái
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.fastOutSlowIn;

    var tween = Tween(begin: begin, end: end);
    var curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    return SlideTransition(
      position: tween.animate(curvedAnimation),
      child: child,
    );
  }
}
