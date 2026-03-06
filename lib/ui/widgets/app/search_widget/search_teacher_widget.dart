import 'package:bsuir/domain/entity/teachers.dart';
import 'package:bsuir/resourses/app_colors.dart';
import 'package:bsuir/ui/widgets/app/search_widget/search_teacher_model.dart';
import 'package:bsuir/resourses/app_fonts.dart';
import 'package:bsuir/ui/widgets/inherited/provider.dart';
import 'package:flutter/material.dart';

class SearchTeacherWidget extends StatefulWidget {
  const SearchTeacherWidget({super.key});

  @override
  State<SearchTeacherWidget> createState() => _SearchTeacherWidgetState();
}

class _SearchTeacherWidgetState extends State<SearchTeacherWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = NotifierProvider.read<SearchTeacherModel>(context);
      model?.refreshFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<SearchTeacherModel>(context);

    if (model == null) return const Center(child: CircularProgressIndicator());
    
    var isSearchingTeachers = model.isSearchingTeachers;
    
    return ColoredBox(
      color: const Color(0xFFf3f2f8),
      child: Stack(
        children: [
          // Основной контент
          _buildMainContent(context, model, isSearchingTeachers),
          
          // Поле поиска
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: SizedBox(
              height: 45,
              child: TextField(
                onChanged: model.searchTeacher,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF88898d)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  hintText: 'Найти преподавателя',
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    height: 1.3,
                    fontFamily: AppFonts.montserrat,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, SearchTeacherModel model, bool isSearching) {
    // При поиске показываем только найденных преподавателей
    if (isSearching) {
      return _buildSearchResults(context, model);
    }
    
    // Без поиска: избранные отдельно + все преподаватели
    return _buildFullListWithFavorites(model);
  }

  Widget _buildFullListWithFavorites(SearchTeacherModel model) {
    final List<Widget> items = [];
    
    // 1. Избранные преподаватели (отдельный блок)
    if (model.favoriteTeachers.isNotEmpty) {
      // Заголовок избранных
      items.add(_buildFavoritesHeader());
      
      // Избранные преподаватели
      items.addAll(
        model.favoriteTeachers.map((teacher) => 
          _buildTeacherItem(teacher, model, isFavorite: true, showInFavoritesBlock: true)
        ).toList(),
      );
      
      // Разделитель между избранными и всеми
      items.add(_buildDivider('Все преподаватели'));
    } else {
      // Если нет избранных, просто заголовок "Все преподаватели"
      items.add(_buildDivider('Все преподаватели'));
    }
    
    // 2. ВСЕ преподаватели (включая избранных)
    // Здесь нужно показать всех преподавателей, даже если они уже есть в избранных
    items.addAll(
      model.teachers.map((teacher) {
        // Проверяем, является ли преподаватель избранным
        final isFavorite = model.favoriteTeachers.any((fav) => fav.urlId == teacher.urlId);
        
        return _buildTeacherItem(
          teacher, 
          model, 
          isFavorite: isFavorite,
          showInFavoritesBlock: false, // Это не в блоке избранных
        );
      }).toList(),
    );
    
    // Если нет преподавателей вообще
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: Text('Нет преподавателей'),
        ),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.only(top: 60),
      children: items,
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchTeacherModel model) {
    if (model.teachers.isEmpty) {
      return const Center(child: Text('Преподаватель не найден'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(top: 60),
      itemCount: model.teachers.length,
      itemBuilder: (BuildContext context, int index) {
        final teacher = model.teachers[index];
        
        // При поиске проверяем, избранный ли преподаватель
        final isFavorite = model.favoriteTeachers.any((fav) => fav.urlId == teacher.urlId);
        
        return _buildTeacherItem(
          teacher, 
          model, 
          isFavorite: isFavorite,
          showInFavoritesBlock: false,
        );
      },
    );
  }

  Widget _buildTeacherItem(
    Teachers teacher, 
    SearchTeacherModel model, 
    {
      required bool isFavorite,
      required bool showInFavoritesBlock,
    }
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          model.onTeacherTap(context, teacher.urlId);
        },
        child: _TeacherRowWidget(
          teacher: teacher,
          isFavorite: isFavorite,
          showInFavoritesBlock: showInFavoritesBlock,
        ),
      ),
    );
  }

  // Заголовок для избранных преподавателей
  Widget _buildFavoritesHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8, right: 20),
      color: const Color(0xFFf3f2f8),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Text(
            'Избранные преподаватели',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.montserrat,
            ),
          ),
        ],
      ),
    );
  }

  // Разделитель с текстом
  Widget _buildDivider(String text) {
    return Container(
      padding: const EdgeInsets.only(left: 20, top: 20, bottom: 8, right: 20),
      color: const Color(0xFFf3f2f8),
      child: Row(
        children: [
          Icon(Icons.people, color: const Color(0xFF88898d), size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.montserrat,
            ),
          ),
        ],
      ),
    );
  }
}

// Обновленный виджет строки преподавателя
class _TeacherRowWidget extends StatelessWidget {
  final Teachers teacher;
  final bool isFavorite;
  final bool showInFavoritesBlock; // true = в блоке избранных, false = в основном списке

  const _TeacherRowWidget({
    super.key, 
    required this.teacher,
    required this.isFavorite,
    required this.showInFavoritesBlock,
  });

  @override
  Widget build(BuildContext context) {
    final photoLink = teacher.photoLink;
    
    // Разный стиль в зависимости от того, где показываем
    final backgroundColor = showInFavoritesBlock
        ? Colors.amber.withOpacity(0.1)  // В блоке избранных - желтый фон
        : (isFavorite 
            ? Colors.amber.withOpacity(0.05)  // В основном списке, но избранный - светлый желтый
            : Colors.white);  // Обычный
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: ClipOval(
                            child: photoLink != null
                                ? Image.network(
                                    photoLink,
                                    width: 45,
                                    height: 45,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person_outline,
                                        color: AppColors.greyBackground,
                                        size: 20,
                                      );
                                    },
                                  )
                                : Icon(
                                    Icons.person_outline,
                                    color: AppColors.blue,
                                    size: 20,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: RichText(
                                      maxLines: 3,
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontFamily: AppFonts.montserrat,
                                          height: 1.3,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(text: teacher.lastName),
                                          const TextSpan(text: ' '),
                                          TextSpan(text: teacher.firstName),
                                          const TextSpan(text: ' '),
                                          if (teacher.middleName != null)
                                            TextSpan(text: teacher.middleName!),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isFavorite && !showInFavoritesBlock)
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              (teacher.academicDepartment == null)
                                  ? const SizedBox(height: 1)
                                  : Wrap(
                                      spacing: 4.0,
                                      runSpacing: 2.0,
                                      children: teacher.academicDepartment!.map(
                                        (academicDepartment) {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                academicDepartment,
                                                style: const TextStyle(
                                                  color: Color(0xFF88898d),
                                                  fontSize: 9,
                                                  fontFamily: AppFonts.montserrat,
                                                  height: 1.2,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ).toList(),
                                    ),
                              (teacher.degree != null && teacher.rank != null)
                                  ? RichText(
                                      maxLines: 3,
                                      text: TextSpan(
                                        style: const TextStyle(
                                          color: Color(0xFF88898d),
                                          fontSize: 9,
                                          fontFamily: AppFonts.montserrat,
                                          height: 1.2,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(text: teacher.degree),
                                          const TextSpan(text: ' '),
                                          TextSpan(text: teacher.rank),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(height: 1),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF88898d),
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
























// import 'package:bsuir/domain/entity/teachers.dart';
// import 'package:bsuir/resourses/app_colors.dart';
// import 'package:bsuir/ui/widgets/app/search_widget/search_teacher_model.dart';
// import 'package:bsuir/resourses/app_fonts.dart';
// import 'package:bsuir/ui/widgets/inherited/provider.dart';
// import 'package:flutter/material.dart';

// class SearchTeacherWidget extends StatelessWidget {
//   const SearchTeacherWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final model = NotifierProvider.watch<SearchTeacherModel>(context);

//     if (model == null) return Center(child: CircularProgressIndicator());
//     var isSearchingGroups = model.isSearchingTeachers;
//     return ColoredBox(
//       color: const Color(0xFFf3f2f8),
//       child: Stack(
//         children: [
//           Container(
//             child: (model.teachers.isEmpty && isSearchingGroups)
//                 ? const Center(child: Text('Преподаватель не найден'))
//                 : ListView.builder(
//                     padding: const EdgeInsets.only(top: 60),
//                     itemCount: model.teachers.length,

//                     itemBuilder: (BuildContext context, int index) {
//                       final teacher = model.teachers[index];
//                        return Material(
//                         color: Colors.transparent,
//                         child: InkWell(
//                           borderRadius: BorderRadius.circular(10),
//                           onTap: () {
//                             return model.onTeacherTap(context, index);
//                             // print(index);
//                           },
//                           child: _TeacherRowWidget(teacher: teacher),
//                         ),
//                       );
                     
//                     },
//                   ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//             child: SizedBox(
//               height: 45,
//               child: TextField(
//                 onChanged: model.searchTeacher,
//                 decoration: InputDecoration(
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xFF88898d)),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.transparent),
//                   ),
//                   hintText: 'Найти преподавателя',
//                   // labelText: 'Найти преподавателя',
//                   hintStyle: TextStyle(
//                     color: Colors.black,
//                     fontSize: 14,
//                     height: 1.3,
//                     fontFamily: AppFonts.montserrat,
//                     // fontWeight: FontWeight.w500,
//                   ),
//                   filled: true,
//                   fillColor: Colors.white, //.withAlpha(235),
//                   border: const OutlineInputBorder(),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TeacherRowWidget extends StatelessWidget {
//   const _TeacherRowWidget({super.key, required this.teacher});

//   final Teachers teacher;

//   @override
//   Widget build(BuildContext context) {
//     final photoLink = teacher.photoLink;
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
//       child: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.all(Radius.circular(10)),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 45,
//                           height: 45,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: Colors.grey[300]!,
//                               width: 1,
//                             ),
//                           ),
//                           child: ClipOval(
//                             child: photoLink != null
//                                 ? Image.network(
//                                     photoLink,
//                                     width: 45,
//                                     height: 45,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Icon(
//                                         Icons.person_outline,
//                                         color: AppColors.greyBackground,
//                                         size: 20,
//                                       );
//                                     },
//                                   )
//                                 : Icon(
//                                     Icons.person_outline,
//                                     color: AppColors.blue,
//                                     size: 20,
//                                   ),
//                           ),
//                         ),
//                         SizedBox(width: 5),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               RichText(
//                                 maxLines: 3,
//                                 text: TextSpan(
//                                   style: TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 14,
//                                     fontFamily: AppFonts.montserrat,
//                                     // fontWeight: FontWeight.w500,
//                                     height: 1.3,
//                                   ),
//                                   children: <TextSpan>[
//                                     TextSpan(text: teacher.lastName),
//                                     const TextSpan(text: ' '),
//                                     TextSpan(text: teacher.firstName),
//                                     const TextSpan(text: ' '),
//                                     TextSpan(text: teacher.middleName),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               (teacher.academicDepartment == null)
//                                   ? SizedBox(height: 1)
//                                   : Wrap(
//                                       spacing: 4.0,
//                                       runSpacing: 2.0,
//                                       children: teacher.academicDepartment!.map(
//                                         (academicDepartment) {
//                                           return Row(
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: [
//                                               Text(
//                                                 academicDepartment,
//                                                 style: const TextStyle(
//                                                   color: Color(0xFF88898d),
//                                                   fontSize: 9,
//                                                   fontFamily:
//                                                       AppFonts.montserrat,

//                                                   height: 1.2,
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       ).toList(),
//                                     ),
//                               (teacher.degree != null &&
//                                       teacher.rank != null) //ПЕРЕДЕЛАТЬ
//                                   ? RichText(
//                                       maxLines: 3,
//                                       text: TextSpan(
//                                         style: TextStyle(
//                                           color: Color(0xFF88898d),
//                                           fontSize: 9,
//                                           fontFamily: AppFonts.montserrat,
//                                           height: 1.2,
//                                         ),
//                                         children: <TextSpan>[
//                                           TextSpan(text: teacher.degree),
//                                           TextSpan(text: ' '),
//                                           TextSpan(text: teacher.rank),
//                                         ],
//                                       ),
//                                     )
//                                   : SizedBox(height: 1),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Icon(
//                     Icons.arrow_forward_ios_rounded,
//                     color: Color(0xFF88898d),
//                     size: 15,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Material(
//             color: Colors.transparent,
//             // child: InkWell(
//             //   borderRadius: BorderRadius.circular(10),
//             //   onTap: () {},
//             // ),
//           ),
//         ],
//       ),
//     );
//   }
// }
