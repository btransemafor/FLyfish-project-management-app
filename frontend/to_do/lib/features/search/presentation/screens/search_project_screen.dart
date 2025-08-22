import 'dart:math';
import 'package:fuzzy/fuzzy.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/core/common/custom_back_button.dart';
import 'package:to_do/features/projects/domain/entities/project_entity.dart';
import 'package:to_do/features/projects/presentation/bloc/project_bloc.dart';
import 'package:to_do/features/projects/presentation/bloc/project_event.dart';
import 'package:to_do/features/projects/presentation/bloc/project_state.dart';
import 'package:to_do/features/projects/presentation/widgets/project_card.dart';
import 'package:to_do/features/search/presentation/widgets/custom_search_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do/features/search/presentation/widgets/empty_result_search.dart';

class SearchProjectScreen extends StatefulWidget {
  const SearchProjectScreen({super.key});

  @override
  State<SearchProjectScreen> createState() => _SearchProjectScreenState();
}

class _SearchProjectScreenState extends State<SearchProjectScreen> {
  final searchController = TextEditingController();
  List<ProjectEntity> filterProjects = [];
  List<ProjectEntity> projects = [];
  bool isSearch = false;
  String sapxep = 'new';
  bool filterCompleted = true;
  bool filterInProgress = false;

  void onClear() {
    setState(() {
      searchController.clear();
      isSearch = false;
    });
  }

  void onSearch() {
    final projectNames = projects.map((p) => p.name).toList();

    // khởi tạo fuzzy search
    final fuse = Fuzzy(
      projectNames,
      options: FuzzyOptions(
        threshold: 0.5,
        findAllMatches: true,
        tokenize: true,
      ),
    );

    // chạy search
    final results = fuse.search(searchController.text);

    // map ngược lại về ProjectEntity
    filterProjects.clear();
    filterProjects = results.map((r) {
      return projects.firstWhere((p) => p.name == r.item);
    }).toList();

    print(filterProjects.length);
    isSearch = true;

    setState(() {});
  }

  void search(String query) {
    // lấy danh sách tên dự án
    final projectNames = projects.map((p) => p.name).toList();

    // khởi tạo fuzzy search
    final fuse = Fuzzy(
      projectNames,
      options: FuzzyOptions(
        threshold: 0.5,
        findAllMatches: true,
        tokenize: true,
      ),
    );

    // chạy search
    final results = fuse.search(query);

    // map ngược lại về ProjectEntity
    filterProjects.clear();
    filterProjects = results.map((r) {
      return projects.firstWhere((p) => p.name == r.item);
    }).toList();

    print(filterProjects.length);

    setState(() {});
  }

  @override
  void initState() {
    print('[Khởi tạo màn hình]');
    super.initState();
    context.read<ProjectBloc>().add(FetchProject());
  }

  @override
  Widget build(BuildContext context) {
    print('Gọi hàm build');
    return BlocListener<ProjectBloc, ProjectState>(
      listener: (context, state) {
        if (state is ProjectSuccess) {
          setState(() {
            projects = state.projects;
          });
        }
      },
      child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Colors.grey.shade100,
            automaticallyImplyLeading: false,
            flexibleSpace: Padding(
              padding: const EdgeInsets.only(left: 5, top: 30, right: 0),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: CustomBackButton(
                        onPress: () {
                          context.pop();
                        },
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      flex: 8,
                      child: SizedBox(
                          height: 40,
                          child: CustomSearchBar(
                              onSearch: onSearch,
                              onClear: onClear,
                              onChanged: (query) {
                                //  search(query);
                              },
                              controller: searchController))),
                ],
              ),
            ),
          ),
          body:
              // CustomSearchBar(controller: searchController)
              Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isSearch && filterProjects.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(left: 15, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Đã tìm thấy ${filterProjects.length} kết quả',
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.blue.shade700,
                            ),
                          ),

                          // Filter
                          Builder(
                            builder: (context) {
                              return Stack(clipBehavior: Clip.none, children: [
                                IconButton(
                                  onPressed: () {
                                    print("Mở bộ lọc");
                                    // TODO: mở bottom sheet hoặc dialog filter
                                    _showBottomFilter(context);
                                  },
                                  icon: const Icon(Icons.filter_alt_outlined),
                                  color: Colors.blue.shade600,
                                  tooltip: "Bộ lọc",
                                ),
                                Positioned(
                                    right: -6,
                                    bottom: 3,
                                    child: Text(
                                      'Lọc',
                                      style: GoogleFonts.poppins(
                                          color: Colors.blueAccent),
                                    ))
                              ]);
                            },
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              Expanded(child: _buildProjectList()),
            ],
          )),
    );
  }

  Widget _buildProjectList() {
    return BlocBuilder<ProjectBloc, ProjectState>(builder: (context, state) {
      if (state is ProjectSuccess) {
        //   final radomColor = randomColor();
        if (state.projects.isEmpty) {
          return Center(
            child: Text('Bạn chưa có bất kì dự án nào'),
          );
        } else {
          // Hiện thị danh sách project

          if (isSearch && filterProjects.isEmpty) {
            return EmptyResultSearch();
          }

          return ListView.builder(
              itemCount: searchController.text.isEmpty
                  ? state.projects.length
                  : filterProjects.length,
              itemBuilder: (context, index) {
                final item = searchController.text.isEmpty
                    ? state.projects[index]
                    : filterProjects[index];
                return ProjectCard(
                  project: item,
                  background: Colors.deepPurple.shade900,
                );
              });
        }
      }
      return CircularProgressIndicator();
    });
  }

  void sortByDateStart(String sapxep) {
    // newest to oldest
    if (sapxep == 'old') {
      setState(() {
        filterProjects.sort((a, b) => a.startDate.compareTo(b.startDate));
      });
    } else if (sapxep == 'new') {
      setState(() {
        filterProjects.sort((a, b) => b.startDate.compareTo(a.startDate));
      });
    }
  }

void filterStatus() {
  // Luôn lọc dựa trên allProjects (danh sách gốc)
  List<ProjectEntity> updated = projects; 
  print(updated); 

  if (filterCompleted && !filterInProgress) {
    updated = projects.where((item) => item.status == 'Completed').toList();
    print(updated.length); 
    print(updated); 
  } 
  else if (filterInProgress && !filterCompleted) {
    updated = projects.where((item) => item.status == 'OnGoing').toList();
  } 
  else if (filterCompleted && filterInProgress) {
    // nếu cả 2 cùng chọn => lấy hết
    updated = projects;
  }

  setState(() {
    filterProjects = updated;
  });
}


  void _showBottomFilter(BuildContext context) async {
    // Biến local để lưu trạng thái chọn


    

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomContext) {
        return StatefulBuilder(
          builder: (context, setStateBottom) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thanh kéo
                  Center(
                    child: Container(
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  Text("Bộ lọc dự án",
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),

                  /// Filter trạng thái
                  Text("Trạng thái",
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilterChip(
                        label: const Text("Hoàn thành"),
                        selected: filterCompleted,
                        onSelected: (val) {
                          setStateBottom(() {
                            filterCompleted = val;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text("Đang thực hiện"),
                        selected: filterInProgress,
                        onSelected: (val) {
                          setStateBottom(() {
                            filterInProgress = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  /// Filter thời gian
                  Text("Sắp xếp theo thời gian",
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text("Mới nhất"),
                        selected: sapxep == 'new',
                        onSelected: (val) {
                          setStateBottom(() {
                            sapxep = 'new';
                            // sortByDateStart(sapxep);
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text("Cũ nhất"),
                        selected: sapxep == 'old',
                        onSelected: (val) {
                          setStateBottom(() {
                            sapxep = 'old';
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 8, 39, 123),
                          ),
                          onPressed: () {
                            setStateBottom(() {
                              // Reset tất cả filter
                              filterCompleted = false;
                              filterInProgress = false;
                              sapxep = 'new';
                            });
                          },
                          child: Text(
                            'Thiết lập lại',
                            style: GoogleFonts.openSans(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: const BorderSide(
                                width: 1, color: Colors.blueAccent),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            sortByDateStart(sapxep);
                            filterStatus(); 
                            // Đóng modal và trả kết quả về widget cha
                            Navigator.pop(bottomContext, {
                              'filterCompleted': filterCompleted,
                              'filterInProgress': filterInProgress,
                              'sapxep': sapxep,
                            });
                          },
                          child: Text(
                            "Áp dụng",
                            style:
                                GoogleFonts.poppins(color: Colors.blueAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // Nhận kết quả filter về widget cha
    if (result != null) {
      print("Kết quả filter: $result");
      // TODO: ở đây có thể setState để áp dụng filter thật
    }
  }
}

Color randomColor() {
  final List<Color> colors = [
    Colors.blueAccent.shade200,
    const Color.fromARGB(255, 134, 7, 7),
    const Color.fromARGB(255, 9, 73, 42),
    const Color.fromARGB(255, 131, 85, 16),
  ];
  final Random random = Random();
  return colors[random.nextInt(colors.length)];
}
