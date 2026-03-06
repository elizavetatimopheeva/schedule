// import 'package:bsuir/domain/entity/groups.dart';
// import 'package:bsuir/resourses/app_colors.dart';
// import 'package:bsuir/ui/widgets/inherited/provider.dart';
// import 'package:flutter/material.dart';
// import 'package:bsuir/resourses/app_fonts.dart';
// import 'package:bsuir/ui/widgets/app/search_widget/search_group_model.dart';

// class SearchGroupWidget extends StatelessWidget {
//   const SearchGroupWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final model = NotifierProvider.watch<SearchGroupModel>(context);
//     if (model == null) return Center(child: CircularProgressIndicator());
//     var isSearchingGroups = model.isSearchingGroups;
//     return ColoredBox(
//       color: AppColors.greyBackground,
//       child: Stack(
//         children: [
//           Container(
//             child: (model.groups.isEmpty && isSearchingGroups)
//                 ? const Center(child: Text('Группа не найдена'))
//                 : ListView.builder(
//                     padding: const EdgeInsets.only(top: 60),
//                     itemCount: model.groups.length,

//                     itemBuilder: (BuildContext context, int index) {
//                       final group = model.groups[index];
//                       return Material(
//                         color: Colors.transparent,
//                         child: InkWell(
//                           borderRadius: BorderRadius.circular(10),
//                           onTap: () {
//                             return model.onGroupTap(context, index);
//                             // print(index);
//                           },
//                           child: _GroupRowWidget(group: group),
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
//                 onChanged: model.searchGroup,
//                 decoration: InputDecoration(
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: AppColors.greyText),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.transparent),
//                   ),
//                   hintText: 'Найти группы',
//                   hintStyle: TextStyle(
//                     color: AppColors.black,
//                     fontSize: 14,
//                     height: 1.3,
//                     fontFamily: AppFonts.montserrat,
//                     // fontWeight: FontWeight.w500,
//                   ),
//                   filled: true,
//                   fillColor: AppColors.white, //.withAlpha(235),
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

// class _GroupRowWidget extends StatelessWidget {
//   final Groups group;

//   _GroupRowWidget({Key? key, required this.group}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
//       child: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               color: AppColors.white,
//               borderRadius: BorderRadius.all(Radius.circular(10)),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           group.name,
//                           style: TextStyle(
//                             color: AppColors.black,
//                             fontSize: 13,
//                             fontFamily: AppFonts.montserrat,
//                             fontWeight: FontWeight.w500,
//                             height: 1.3,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           group.facultyName,
//                           maxLines: 2,
//                           style: TextStyle(
//                             color: AppColors.greyText,
//                             fontSize: 11,
//                             fontFamily: AppFonts.montserrat,
//                             height: 1.1,
//                           ),
//                         ),
//                         Text(
//                           group.specialityName,
//                           maxLines: 2,
//                           style: TextStyle(
//                             color: AppColors.greyText,
//                             fontSize: 11,
//                             fontFamily: AppFonts.montserrat,
//                             height: 1.1,
//                           ),
//                         ),
//                         (group.course) != null
//                             ? Text(
//                                 '${group.course} курс',
//                                 maxLines: 2,
//                                 style: TextStyle(
//                                   color: AppColors.greyText,
//                                   fontSize: 11,
//                                   fontFamily: AppFonts.montserrat,
//                                   height: 1.3,
//                                 ),
//                               )
//                             : SizedBox.shrink(),
//                       ],
//                     ),
//                   ),
//                   const Icon(
//                     Icons.arrow_forward_ios_rounded,
//                     color: AppColors.greyText,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }














// import 'package:bsuir/domain/entity/groups.dart';
// import 'package:bsuir/resourses/app_colors.dart';
// import 'package:bsuir/ui/widgets/inherited/provider.dart';
// import 'package:flutter/material.dart';
// import 'package:bsuir/resourses/app_fonts.dart';
// import 'package:bsuir/ui/widgets/app/search_widget/search_group_model.dart';

// class SearchGroupWidget extends StatefulWidget {
//   const SearchGroupWidget({super.key});

//   @override
//   State<SearchGroupWidget> createState() => _SearchGroupWidgetState();
// }

// class _SearchGroupWidgetState extends State<SearchGroupWidget> {
//   final Map<String, bool> _favoriteCache = {};
//   final ScrollController _scrollController = ScrollController();

//   @override
//   Widget build(BuildContext context) {
//     final model = NotifierProvider.watch<SearchGroupModel>(context);
    
//     if (model == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return ColoredBox(
//       color: AppColors.greyBackground,
//       child: Stack(
//         children: [
//           _buildGroupsList(model),
//           _buildSearchField(model),
//         ],
//       ),
//     );
//   }

//   Widget _buildGroupsList(SearchGroupModel model) {
//     final groups = model.groups;
//     final isSearching = model.isSearchingGroups;
    
//     // Разделяем группы на избранные и остальные
//     final favoriteGroups = groups.where((g) => _favoriteCache[g.name] ?? false).toList();
//     final otherGroups = groups.where((g) => !(_favoriteCache[g.name] ?? false)).toList();
    
//     final hasFavorites = favoriteGroups.isNotEmpty;
//     final hasGroups = groups.isNotEmpty;
//     final showEmptyState = !hasGroups && isSearching;
//     final showNoFavorites = !isSearching && !hasFavorites && hasGroups;

//     return ListView(
//       controller: _scrollController,
//       padding: const EdgeInsets.only(top: 60),
//       children: [
//         // Заголовок для избранных (только если они есть и не идет поиск)
//         if (hasFavorites && !isSearching)
//           _buildFavoritesHeader(favoriteGroups.length),
        
//         // Избранные группы
//         if (hasFavorites && !isSearching)
//           ...favoriteGroups.map((group) => 
//             _buildGroupItem(group, model, true)
//           ).toList(),
        
//         // Заголовок для всех групп
//         if (!isSearching && (hasFavorites || showNoFavorites))
//           _buildAllGroupsHeader(),
        
//         // Все остальные группы
//         if (hasGroups)
//           ...otherGroups.map((group) => 
//             _buildGroupItem(group, model, false)
//           ).toList(),
        
//         // Состояния (они занимают весь экран, поэтому в центре)
//         if (showEmptyState)
//           Container(
//             height: MediaQuery.of(context).size.height * 0.7,
//             child: _buildEmptyState(),
//           ),
        
//         if (showNoFavorites && !isSearching)
//           Container(
//             height: MediaQuery.of(context).size.height * 0.7,
//             child: _buildNoFavoritesHint(),
//           ),
//       ],
//     );
//   }

//   Widget _buildGroupItem(Groups group, SearchGroupModel model, bool isFavorite) {
//     return FutureBuilder<bool>(
//       future: model.isGroupFavorite(group.name),
//       builder: (context, snapshot) {
//         final isCurrentlyFavorite = snapshot.data ?? false;
        
//         // Обновляем кэш
//         if (snapshot.hasData) {
//           _favoriteCache[group.name] = isCurrentlyFavorite;
//         }
        
//         return Material(
//           color: Colors.transparent,
//           child: InkWell(
//             borderRadius: BorderRadius.circular(10),
//             onTap: () => model.onGroupTap(context, _findGroupIndex(group, model)),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   group.name,
//                                   style: TextStyle(
//                                     color: AppColors.black,
//                                     fontSize: 13,
//                                     fontFamily: AppFonts.montserrat,
//                                     fontWeight: FontWeight.w500,
//                                     height: 1.3,
//                                   ),
//                                 ),
//                                 const Spacer(),
//                                 IconButton(
//                                   padding: EdgeInsets.zero,
//                                   constraints: const BoxConstraints(),
//                                   icon: Icon(
//                                     isCurrentlyFavorite ? Icons.star : Icons.star_border,
//                                     color: isCurrentlyFavorite ? Colors.amber : AppColors.greyText,
//                                     size: 20,
//                                   ),
//                                   onPressed: () async {
//                                     await model.toggleGroupFavorite(group.name);
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                           isCurrentlyFavorite 
//                                             ? 'Группа удалена из избранного'
//                                             : 'Группа добавлена в избранное',
//                                         ),
//                                         duration: const Duration(seconds: 1),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               group.facultyName,
//                               maxLines: 2,
//                               style: TextStyle(
//                                 color: AppColors.greyText,
//                                 fontSize: 11,
//                                 fontFamily: AppFonts.montserrat,
//                                 height: 1.1,
//                               ),
//                             ),
//                             Text(
//                               group.specialityName,
//                               maxLines: 2,
//                               style: TextStyle(
//                                 color: AppColors.greyText,
//                                 fontSize: 11,
//                                 fontFamily: AppFonts.montserrat,
//                                 height: 1.1,
//                               ),
//                             ),
//                             if (group.course != null)
//                               Text(
//                                 '${group.course} курс',
//                                 maxLines: 2,
//                                 style: TextStyle(
//                                   color: AppColors.greyText,
//                                   fontSize: 11,
//                                   fontFamily: AppFonts.montserrat,
//                                   height: 1.3,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                       const Icon(
//                         Icons.arrow_forward_ios_rounded,
//                         color: AppColors.greyText,
//                         size: 16,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSearchField(SearchGroupModel model) {
//     return Positioned(
//       top: 0,
//       left: 0,
//       right: 0,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//         child: SizedBox(
//           height: 45,
//           child: TextField(
//             onChanged: model.searchGroup,
//             decoration: InputDecoration(
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: AppColors.greyText),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: AppColors.blue),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               hintText: 'Найти группы',
//               hintStyle: TextStyle(
//                 color: AppColors.greyText,
//                 fontSize: 14,
//                 height: 1.3,
//                 fontFamily: AppFonts.montserrat,
//               ),
//               filled: true,
//               fillColor: AppColors.white,
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 12,
//               ),
//               prefixIcon: Icon(
//                 Icons.search,
//                 color: AppColors.greyText,
//                 size: 20,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFavoritesHeader(int count) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 8),
//       child: Row(
//         children: [
//           Icon(Icons.star, color: Colors.amber, size: 18),
//           const SizedBox(width: 8),
//           Text(
//             'Избранные группы ($count)',
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               fontFamily: AppFonts.montserrat,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAllGroupsHeader() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
//       child: Row(
//         children: [
//           Icon(Icons.groups, color: AppColors.greyText, size: 18),
//           const SizedBox(width: 8),
//           Text(
//             'Все группы',
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               fontFamily: AppFonts.montserrat,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.search_off,
//             size: 64,
//             color: AppColors.greyText,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Группа не найдена',
//             style: TextStyle(
//               color: AppColors.greyText,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               fontFamily: AppFonts.montserrat,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Попробуйте изменить запрос',
//             style: TextStyle(
//               color: AppColors.greyText,
//               fontSize: 14,
//               fontFamily: AppFonts.montserrat,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNoFavoritesHint() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.star_border,
//             size: 64,
//             color: AppColors.greyText,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Нет избранных групп',
//             style: TextStyle(
//               color: AppColors.greyText,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               fontFamily: AppFonts.montserrat,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: Text(
//               'Добавляйте группы в избранное, нажимая на звездочку рядом с названием группы',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: AppColors.greyText,
//                 fontSize: 13,
//                 fontFamily: AppFonts.montserrat,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   int _findGroupIndex(Groups group, SearchGroupModel model) {
//     return model.groups.indexWhere((g) => g.name == group.name);
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _favoriteCache.clear();
//     super.dispose();
//   }
// }




// import 'package:bsuir/domain/entity/groups.dart';
// import 'package:bsuir/resourses/app_colors.dart';
// import 'package:bsuir/ui/widgets/inherited/provider.dart';
// import 'package:flutter/material.dart';
// import 'package:bsuir/resourses/app_fonts.dart';
// import 'package:bsuir/ui/widgets/app/search_widget/search_group_model.dart';

// class SearchGroupWidget extends StatefulWidget {
//   const SearchGroupWidget({super.key});

//   @override
//   State<SearchGroupWidget> createState() => _SearchGroupWidgetState();
// }

// class _SearchGroupWidgetState extends State<SearchGroupWidget> {
//   final Map<String, bool> _favoriteCache = {};
//   final ScrollController _scrollController = ScrollController();

//   @override
//   Widget build(BuildContext context) {
//     final model = NotifierProvider.watch<SearchGroupModel>(context);
    
//     if (model == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return ColoredBox(
//       color: AppColors.greyBackground,
//       child: Stack(
//         children: [
//           _buildGroupsList(model),
//           _buildSearchField(model),
//         ],
//       ),
//     );
//   }

//   Widget _buildGroupsList(SearchGroupModel model) {
//     final groups = model.groups;
//     final isSearching = model.isSearchingGroups;
    
//     // Разделяем группы на избранные и остальные
//     final favoriteGroups = groups.where((g) => _favoriteCache[g.name] ?? false).toList();
//     final otherGroups = groups.where((g) => !(_favoriteCache[g.name] ?? false)).toList();
    
//     final hasFavorites = favoriteGroups.isNotEmpty;
//     final hasGroups = groups.isNotEmpty;
//     final showEmptyState = !hasGroups && isSearching;
//     final showNoFavorites = !isSearching && !hasFavorites && hasGroups;

//     return ListView(
//       controller: _scrollController,
//       padding: const EdgeInsets.only(top: 60),
//       children: [
//         // Заголовок для избранных (только если они есть и не идет поиск)
//         if (hasFavorites && !isSearching)
//           _buildFavoritesHeader(favoriteGroups.length),
        
//         // Избранные группы
//         if (hasFavorites && !isSearching)
//           ...favoriteGroups.map((group) => 
//             _buildGroupItem(group, model, true)
//           ).toList(),
        
//         // Заголовок для всех групп
//         if (!isSearching && (hasFavorites || showNoFavorites))
//           _buildAllGroupsHeader(),
        
//         // Все остальные группы
//         if (hasGroups)
//           ...otherGroups.map((group) => 
//             _buildGroupItem(group, model, false)
//           ).toList(),
        
//         // Состояния (они занимают весь экран, поэтому в центре)
//         if (showEmptyState)
//           Container(
//             height: MediaQuery.of(context).size.height * 0.7,
//             child: _buildEmptyState(),
//           ),
        
//         if (showNoFavorites && !isSearching)
//           Container(
//             height: MediaQuery.of(context).size.height * 0.7,
//             child: _buildNoFavoritesHint(),
//           ),
//       ],
//     );
//   }

//   Widget _buildGroupItem(Groups group, SearchGroupModel model, bool isFavorite) {
//     return FutureBuilder<bool>(
//       future: model.isGroupFavorite(group.name),
//       builder: (context, snapshot) {
//         final isCurrentlyFavorite = snapshot.data ?? false;
        
//         // Обновляем кэш
//         if (snapshot.hasData) {
//           _favoriteCache[group.name] = isCurrentlyFavorite;
//         }
        
//         return Material(
//           color: Colors.transparent,
//           child: InkWell(
//             borderRadius: BorderRadius.circular(10),
//             onTap: () => model.onGroupTap(context, _findGroupIndex(group, model)),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   group.name,
//                                   style: TextStyle(
//                                     color: AppColors.black,
//                                     fontSize: 13,
//                                     fontFamily: AppFonts.montserrat,
//                                     fontWeight: FontWeight.w500,
//                                     height: 1.3,
//                                   ),
//                                 ),
//                                 const Spacer(),
//                                 IconButton(
//                                   padding: EdgeInsets.zero,
//                                   constraints: const BoxConstraints(),
//                                   icon: Icon(
//                                     isCurrentlyFavorite ? Icons.star : Icons.star_border,
//                                     color: isCurrentlyFavorite ? Colors.amber : AppColors.greyText,
//                                     size: 20,
//                                   ),
//                                   onPressed: () async {
//                                     await model.toggleGroupFavorite(group.name);
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                           isCurrentlyFavorite 
//                                             ? 'Группа удалена из избранного'
//                                             : 'Группа добавлена в избранное',
//                                         ),
//                                         duration: const Duration(seconds: 1),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               group.facultyName,
//                               maxLines: 2,
//                               style: TextStyle(
//                                 color: AppColors.greyText,
//                                 fontSize: 11,
//                                 fontFamily: AppFonts.montserrat,
//                                 height: 1.1,
//                               ),
//                             ),
//                             Text(
//                               group.specialityName,
//                               maxLines: 2,
//                               style: TextStyle(
//                                 color: AppColors.greyText,
//                                 fontSize: 11,
//                                 fontFamily: AppFonts.montserrat,
//                                 height: 1.1,
//                               ),
//                             ),
//                             if (group.course != null)
//                               Text(
//                                 '${group.course} курс',
//                                 maxLines: 2,
//                                 style: TextStyle(
//                                   color: AppColors.greyText,
//                                   fontSize: 11,
//                                   fontFamily: AppFonts.montserrat,
//                                   height: 1.3,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                       const Icon(
//                         Icons.arrow_forward_ios_rounded,
//                         color: AppColors.greyText,
//                         size: 16,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSearchField(SearchGroupModel model) {
//     return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//             child: SizedBox(
//               height: 45,
//               child: TextField(
//                 onChanged: model.searchGroup,
//                 decoration: InputDecoration(
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: AppColors.greyText),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.transparent),
//                   ),
//                   hintText: 'Найти группы',
//                   hintStyle: TextStyle(
//                     color: AppColors.black,
//                     fontSize: 14,
//                     height: 1.3,
//                     fontFamily: AppFonts.montserrat,
//                     // fontWeight: FontWeight.w500,
//                   ),
//                   filled: true,
//                   fillColor: AppColors.white, //.withAlpha(235),
//                   border: const OutlineInputBorder(),
//                 ),
//               ),
//             ),
//           );
//   }

//   Widget _buildFavoritesHeader(int count) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 8),
//       child: Row(
//         children: [
//           Icon(Icons.star, color: Colors.amber, size: 18),
//           const SizedBox(width: 8),
//           Text(
//             'Избранные группы ($count)',
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               fontFamily: AppFonts.montserrat,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAllGroupsHeader() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
//       child: Row(
//         children: [
//           Icon(Icons.groups, color: AppColors.greyText, size: 18),
//           const SizedBox(width: 8),
//           Text(
//             'Все группы',
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               fontFamily: AppFonts.montserrat,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.search_off,
//             size: 64,
//             color: AppColors.greyText,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Группа не найдена',
//             style: TextStyle(
//               color: AppColors.greyText,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               fontFamily: AppFonts.montserrat,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Попробуйте изменить запрос',
//             style: TextStyle(
//               color: AppColors.greyText,
//               fontSize: 14,
//               fontFamily: AppFonts.montserrat,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNoFavoritesHint() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.star_border,
//             size: 64,
//             color: AppColors.greyText,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Нет избранных групп',
//             style: TextStyle(
//               color: AppColors.greyText,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               fontFamily: AppFonts.montserrat,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: Text(
//               'Добавляйте группы в избранное, нажимая на звездочку рядом с названием группы',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: AppColors.greyText,
//                 fontSize: 13,
//                 fontFamily: AppFonts.montserrat,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   int _findGroupIndex(Groups group, SearchGroupModel model) {
//     return model.groups.indexWhere((g) => g.name == group.name);
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _favoriteCache.clear();
//     super.dispose();
//   }
// }


















// import 'package:bsuir/domain/entity/groups.dart';
// import 'package:bsuir/resourses/app_colors.dart';
// import 'package:bsuir/ui/widgets/inherited/provider.dart';
// import 'package:flutter/material.dart';
// import 'package:bsuir/resourses/app_fonts.dart';
// import 'package:bsuir/ui/widgets/app/search_widget/search_group_model.dart';

// class SearchGroupWidget extends StatefulWidget {
//   const SearchGroupWidget({super.key});

//   @override
//   State<SearchGroupWidget> createState() => _SearchGroupWidgetState();
// }

// class _SearchGroupWidgetState extends State<SearchGroupWidget> {
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Обновляем список при каждом возвращении на экран
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final model = NotifierProvider.read<SearchGroupModel>(context);
//       model?.refreshFavorites();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final model = NotifierProvider.watch<SearchGroupModel>(context);
//     if (model == null) return const Center(child: CircularProgressIndicator());
    
//     var isSearchingGroups = model.isSearchingGroups;
    
//     return ColoredBox(
//       color: AppColors.greyBackground,
//       child: Stack(
//         children: [
//           Container(
//             child: _buildMainList(context, model, isSearchingGroups),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//             child: SizedBox(
//               height: 45,
//               child: TextField(
//                 onChanged: model.searchGroup,
//                 decoration: InputDecoration(
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: AppColors.greyText),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.transparent),
//                   ),
//                   hintText: 'Найти группы',
//                   hintStyle: TextStyle(
//                     color: AppColors.black,
//                     fontSize: 14,
//                     height: 1.3,
//                     fontFamily: AppFonts.montserrat,
//                   ),
//                   filled: true,
//                   fillColor: AppColors.white,
//                   border: const OutlineInputBorder(),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMainList(BuildContext context, SearchGroupModel model, bool isSearchingGroups) {
//     // При поиске показываем только найденные группы
//     if (isSearchingGroups) {
//       return _buildSearchResults(context, model);
//     }
    
//     // Без поиска собираем все элементы
//     final List<Widget> items = [];
    
//     // Добавляем избранные группы и заголовок
//     if (model.favoriteGroups.isNotEmpty) {
//       items.add(_buildFavoritesHeader());
//       items.addAll(
//         model.favoriteGroups.map((group) => 
//           Material(
//             color: Colors.transparent,
//             child: InkWell(
//               borderRadius: BorderRadius.circular(10),
//               onTap: () {
//                 model.onGroupTap(context, group.name);
//               },
//               child: _GroupRowWidget(group: group),
//             ),
//           )
//         ).toList(),
//       );
      
//       // Добавляем разделитель между избранными и обычными группами
//       items.add(_buildDivider('Все группы'));
//     }
    
//     // Добавляем все остальные группы (кроме тех, что уже в избранном)
//     final otherGroups = model.groups.where((group) => 
//       !model.favoriteGroups.any((fav) => fav.name == group.name)
//     ).toList();
    
//     if (otherGroups.isNotEmpty || model.favoriteGroups.isEmpty) {
//       // Если нет избранных, добавляем заголовок "Все группы"
//       if (model.favoriteGroups.isEmpty) {
//         items.add(_buildDivider('Все группы'));
//       }
      
//       items.addAll(
//         otherGroups.map((group) => 
//           Material(
//             color: Colors.transparent,
//             child: InkWell(
//               borderRadius: BorderRadius.circular(10),
//               onTap: () {
//                 model.onGroupTap(context, group.name);
//               },
//               child: _GroupRowWidget(group: group),
//             ),
//           )
//         ).toList(),
//       );
//     }
    
//     // Если нет групп вообще
//     if (items.isEmpty) {
//       return const Center(
//         child: Padding(
//           padding: EdgeInsets.only(top: 100),
//           child: Text('Нет групп'),
//         ),
//       );
//     }
    
//     return ListView(
//       padding: const EdgeInsets.only(top: 60),
//       children: items,
//     );
//   }

//   Widget _buildSearchResults(BuildContext context, SearchGroupModel model) {
//     if (model.groups.isEmpty) {
//       return const Center(child: Text('Группа не найдена'));
//     }
    
//     return ListView.builder(
//       padding: const EdgeInsets.only(top: 60),
//       itemCount: model.groups.length,
//       itemBuilder: (BuildContext context, int index) {
//         final group = model.groups[index];
//         return Material(
//           color: Colors.transparent,
//           child: InkWell(
//             borderRadius: BorderRadius.circular(10),
//             onTap: () {
//               model.onGroupTap(context, group.name);
//             },
//             child: _GroupRowWidget(group: group),
//           ),
//         );
//       },
//     );
//   }

//   // Заголовок для избранных групп
//   Widget _buildFavoritesHeader() {
//     return Container(
//       padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8, right: 20),
//       color: AppColors.greyBackground,
//       child: Row(
//         children: [
//           Icon(Icons.star, color: Colors.amber, size: 18),
//           const SizedBox(width: 8),
//           Text(
//             'Избранные группы',
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               fontFamily: AppFonts.montserrat,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Разделитель с текстом
//   Widget _buildDivider(String text) {
//     return Container(
//       padding: const EdgeInsets.only(left: 20, top: 20, bottom: 8, right: 20),
//       color: AppColors.greyBackground,
//       child: Row(
//         children: [
//           Icon(Icons.groups, color: AppColors.greyText, size: 18),
//           const SizedBox(width: 8),
//           Text(
//             text,
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               fontFamily: AppFonts.montserrat,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Виджет строки группы остается БЕЗ ИЗМЕНЕНИЙ
// class _GroupRowWidget extends StatelessWidget {
//   final Groups group;

//   const _GroupRowWidget({Key? key, required this.group}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
//       child: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               color: AppColors.white,
//               borderRadius: BorderRadius.all(Radius.circular(10)),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           group.name,
//                           style: TextStyle(
//                             color: AppColors.black,
//                             fontSize: 13,
//                             fontFamily: AppFonts.montserrat,
//                             fontWeight: FontWeight.w500,
//                             height: 1.3,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           group.facultyName,
//                           maxLines: 2,
//                           style: TextStyle(
//                             color: AppColors.greyText,
//                             fontSize: 11,
//                             fontFamily: AppFonts.montserrat,
//                             height: 1.1,
//                           ),
//                         ),
//                         Text(
//                           group.specialityName,
//                           maxLines: 2,
//                           style: TextStyle(
//                             color: AppColors.greyText,
//                             fontSize: 11,
//                             fontFamily: AppFonts.montserrat,
//                             height: 1.1,
//                           ),
//                         ),
//                         (group.course) != null
//                             ? Text(
//                                 '${group.course} курс',
//                                 maxLines: 2,
//                                 style: TextStyle(
//                                   color: AppColors.greyText,
//                                   fontSize: 11,
//                                   fontFamily: AppFonts.montserrat,
//                                   height: 1.3,
//                                 ),
//                               )
//                             : const SizedBox.shrink(),
//                       ],
//                     ),
//                   ),
//                   const Icon(
//                     Icons.arrow_forward_ios_rounded,
//                     color: AppColors.greyText,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }















import 'package:bsuir/domain/entity/groups.dart';
import 'package:bsuir/resourses/app_colors.dart';
import 'package:bsuir/ui/widgets/inherited/provider.dart';
import 'package:flutter/material.dart';
import 'package:bsuir/resourses/app_fonts.dart';
import 'package:bsuir/ui/widgets/app/search_widget/search_group_model.dart';

class SearchGroupWidget extends StatefulWidget {
  const SearchGroupWidget({super.key});

  @override
  State<SearchGroupWidget> createState() => _SearchGroupWidgetState();
}

class _SearchGroupWidgetState extends State<SearchGroupWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = NotifierProvider.read<SearchGroupModel>(context);
      model?.refreshFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<SearchGroupModel>(context);
    if (model == null) return const Center(child: CircularProgressIndicator());
    
    var isSearchingGroups = model.isSearchingGroups;
    
    return ColoredBox(
      color: AppColors.greyBackground,
      child: Stack(
        children: [
          // Основной контент
          _buildMainContent(context, model, isSearchingGroups),
          
          // Поле поиска
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: SizedBox(
              height: 45,
              child: TextField(
                onChanged: model.searchGroup,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.greyText),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  hintText: 'Найти группы',
                  hintStyle: TextStyle(
                    color: AppColors.black,
                    fontSize: 14,
                    height: 1.3,
                    fontFamily: AppFonts.montserrat,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, SearchGroupModel model, bool isSearching) {
    // При поиске показываем только найденные группы
    if (isSearching) {
      return _buildSearchResults(context, model);
    }
    
    // Без поиска: избранные отдельно + все группы
    return _buildFullListWithFavorites(model);
  }

  Widget _buildFullListWithFavorites(SearchGroupModel model) {
    final List<Widget> items = [];
    
    // 1. Избранные группы (отдельный блок)
    if (model.favoriteGroups.isNotEmpty) {
      // Заголовок избранных
      items.add(_buildFavoritesHeader());
      
      // Избранные группы
      items.addAll(
        model.favoriteGroups.map((group) => 
          _buildGroupItem(group, model, isFavorite: true, showInFavoritesBlock: true)
        ).toList(),
      );
      
      // Разделитель между избранными и всеми
      items.add(_buildDivider('Все группы'));
    } else {
      // Если нет избранных, просто заголовок "Все группы"
      items.add(_buildDivider('Все группы'));
    }
    
    // 2. ВСЕ группы (включая избранные)
    // Здесь нужно показать все группы, даже если они уже есть в избранных
    items.addAll(
      model.groups.map((group) {
        // Проверяем, является ли группа избранной
        final isFavorite = model.favoriteGroups.any((fav) => fav.name == group.name);
        
        return _buildGroupItem(
          group, 
          model, 
          isFavorite: isFavorite,
          showInFavoritesBlock: false, // Это не в блоке избранных
        );
      }).toList(),
    );
    
    // Если нет групп вообще
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: Text('Нет групп'),
        ),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.only(top: 60),
      children: items,
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchGroupModel model) {
    if (model.groups.isEmpty) {
      return const Center(child: Text('Группа не найдена'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(top: 60),
      itemCount: model.groups.length,
      itemBuilder: (BuildContext context, int index) {
        final group = model.groups[index];
        
        // При поиске проверяем, избранная ли группа
        final isFavorite = model.favoriteGroups.any((fav) => fav.name == group.name);
        
        return _buildGroupItem(
          group, 
          model, 
          isFavorite: isFavorite,
          showInFavoritesBlock: false,
        );
      },
    );
  }

  Widget _buildGroupItem(
    Groups group, 
    SearchGroupModel model, 
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
          model.onGroupTap(context, group.name);
        },
        child: _GroupRowWidget(
          group: group,
          isFavorite: isFavorite,
          showInFavoritesBlock: showInFavoritesBlock,
        ),
      ),
    );
  }

  // Заголовок для избранных групп
  Widget _buildFavoritesHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8, right: 20),
      color: AppColors.greyBackground,
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Text(
            'Избранные группы',
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
      color: AppColors.greyBackground,
      child: Row(
        children: [
          Icon(Icons.groups, color: AppColors.greyText, size: 18),
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

// Обновленный виджет строки группы
class _GroupRowWidget extends StatelessWidget {
  final Groups group;
  final bool isFavorite;
  final bool showInFavoritesBlock; // true = в блоке избранных, false = в основном списке

  const _GroupRowWidget({
    Key? key, 
    required this.group,
    required this.isFavorite,
    required this.showInFavoritesBlock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Разный стиль в зависимости от того, где показываем
    final backgroundColor = showInFavoritesBlock
        ? Colors.amber.withOpacity(0.1)  // В блоке избранных - желтый фон
        : (isFavorite 
            ? Colors.amber.withOpacity(0.05)  // В основном списке, но избранная - светлый желтый
            : AppColors.white);  // Обычная
    
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              group.name,
                              style: TextStyle(
                                color: AppColors.black,
                                fontSize: 13,
                                fontFamily: AppFonts.montserrat,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                            const Spacer(),
                            if (isFavorite && !showInFavoritesBlock)
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          group.facultyName,
                          maxLines: 2,
                          style: TextStyle(
                            color: AppColors.greyText,
                            fontSize: 11,
                            fontFamily: AppFonts.montserrat,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          group.specialityName,
                          maxLines: 2,
                          style: TextStyle(
                            color: AppColors.greyText,
                            fontSize: 11,
                            fontFamily: AppFonts.montserrat,
                            height: 1.1,
                          ),
                        ),
                        (group.course) != null
                            ? Text(
                                '${group.course} курс',
                                maxLines: 2,
                                style: TextStyle(
                                  color: AppColors.greyText,
                                  fontSize: 11,
                                  fontFamily: AppFonts.montserrat,
                                  height: 1.3,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.greyText,
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