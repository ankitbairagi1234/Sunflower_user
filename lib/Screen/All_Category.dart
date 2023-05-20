import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Provider/CategoryProvider.dart';
import 'package:eshop_multivendor/Provider/HomeProvider.dart';
import 'package:eshop_multivendor/Screen/SubCategory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../Helper/Session.dart';
import '../Model/Section_Model.dart';
import '../Provider/UserProvider.dart';
import 'Cart.dart';
import 'Favorite.dart';
import 'HomePage.dart';
import 'Login.dart';
import 'NotificationLIst.dart';
import 'ProductList.dart';
import 'Search.dart';

class AllCategory extends StatefulWidget {

  @override
  State<AllCategory> createState() => _AllCategoryState();
}

class _AllCategoryState extends State<AllCategory> {
  @override
  void initState() {
    super.initState();
    getCat();
  }

  void getCat() {
    Map parameter = {
      CAT_FILTER: "false",
    };
    apiBaseHelper.postAPICall(getCatApi, parameter).then((getdata) {
      print("_________________________getcategories${getCatApi.toString()}");
      print('_parameteris here__________________${parameter}');
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        catList =
            (data as List).map((data) => new Product.fromCat(data)).toList();

        if (getdata.containsKey("popular_categories")) {
          var data = getdata["popular_categories"];
          popularList =
              (data as List).map((data) => new Product.fromCat(data)).toList();
          if (popularList.length > 0) {
            Product pop =
            new Product.popular("Popular", imagePath + "popular.svg");
            catList.insert(0, pop);
            context.read<CategoryProvider>().setSubList(popularList);
          }
        }
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setCatLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setCatLoading(false);
    });
  }


  // Future<void> getCat() async {
  //   await Future.delayed(Duration.zero);
  //   Map parameter = {
  //     CAT_FILTER: "false",
  //   };
  //   apiBaseHelper.postAPICall(getCatApi, parameter).then((getdata) {
  //     bool error = getdata["error"];
  //     String? msg = getdata["message"];
  //     if (!error) {
  //       var data = getdata["data"];
  //
  //       catList =
  //           (data as List).map((data) => new Product.fromCat(data)).toList();
  //
  //       if (getdata.containsKey("popular_categories")) {
  //         var data = getdata["popular_categories"];
  //         popularList =
  //             (data as List).map((data) => new Product.fromCat(data)).toList();
  //
  //         if (popularList.length > 0) {
  //           Product pop =
  //               new Product.popular("Popular", imagePath + "popular.svg");
  //           catList.insert(0, pop);
  //           context.read<CategoryProvider>().setSubList(popularList);
  //         }
  //       }
  //     } else {
  //       setSnackbar(msg!, context);
  //     }
  //
  //     context.read<HomeProvider>().setCatLoading(false);
  //   }, onError: (error) {
  //     setSnackbar(error.toString(), context);
  //     context.read<HomeProvider>().setCatLoading(false);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: Theme.of(context).colorScheme.white,
        // leading: Builder(
        //   builder: (BuildContext context) {
        //     return Container(
        //       margin: EdgeInsets.all(10),
        //       child: InkWell(
        //         borderRadius: BorderRadius.circular(4),
        //         onTap: () => Navigator.of(context).pop(),
        //         child: Center(
        //           child: Icon(
        //             Icons.arrow_back_ios_rounded,
        //             color: colors.primary,
        //           ),
        //         ),
        //       ),
        //     );
        //   },
        // ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            'CATEGORIES',
            style: TextStyle(color: colors.primary, fontWeight: FontWeight.normal),
          ),
        ),
        actions: <Widget>[
          IconButton(
              icon: SvgPicture.asset(
                imagePath + "search.svg",
                height: 20,
                color: colors.primary,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Search(),
                    ));
              }),
          IconButton(
            icon: SvgPicture.asset(
              imagePath + "desel_notification.svg",
              color: colors.primary,
            ),
            onPressed: () {
              CUR_USERID != null
                  ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationList(),
                  ))
                  : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ));
            },
          ),
          IconButton(
            padding: EdgeInsets.all(0),
            icon: SvgPicture.asset(
              imagePath + "desel_fav.svg",
              color: colors.primary,
            ),
            onPressed: () {
              CUR_USERID != null
                  ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Favorite(),
                  ))
                  : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ));
            },
          ),

        ],
      ),
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, _) {
          if (homeProvider.catLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return catList.length > 0
              ? Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    // _catList(),
                    Expanded(
                      child: Selector<CategoryProvider, List<Product>>(
                        builder: (context, data, child) {
                          return  GridView.builder(
                            // physics: NeverScrollableScrollPhysics(),
                            itemCount:  catList.length,
                            scrollDirection: Axis.vertical,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount
                              (crossAxisCount: 3,mainAxisSpacing: 10), itemBuilder: (context, index) {
                            if (catList.isEmpty)
                              return  Center(
                                  child:
                                  Text(getTranslated(context, 'noItem')!));
                            else
                              return Padding(
                                padding: const EdgeInsetsDirectional.only(end: 10),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (catList[index].subList == null ||
                                        catList[index].subList!.length == 0) {
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProductList(
                                              name: catList[index].name,
                                              id: catList[index].id,
                                              tag: false,
                                              fromSeller: false,
                                            ),
                                          ));
                                    } else {
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SubCategory(
                                              title: catList[index].name!,
                                              subList: catList[index].subList,
                                              catId: catList[index].id,
                                            ),
                                          ));
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10)),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsetsDirectional.only(
                                              bottom: 5.0),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: new FadeInImage(
                                              fadeInDuration: Duration(milliseconds: 150),
                                              image: CachedNetworkImageProvider(
                                                catList[index].image!,
                                              ),
                                              height: 100.0,
                                              // width: 100.0,
                                              fit: BoxFit.fill,
                                              imageErrorBuilder:
                                                  (context, error, stackTrace) =>
                                                  erroWidget(50),
                                              placeholder: placeHolder(50),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          child: Text(
                                            catList[index].name!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1!
                                                .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .fontColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                          },);

                        },
                        selector: (_, categoryProvider) =>
                        categoryProvider.subList,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Expanded(
                    //   child: Selector<CategoryProvider, List<Product>>(
                    //     builder: (context, data, child) {
                    //       return data.length > 0
                    //           ? GridView.count(
                    //               padding: EdgeInsets.symmetric(horizontal: 20),
                    //               crossAxisCount: 3,
                    //               shrinkWrap: true,
                    //               crossAxisSpacing: 5,
                    //               children: List.generate(
                    //                 data.length,
                    //                 (index) {
                    //                   return subCatItem(data, index, context);
                    //                 },
                    //               ))
                    //           : Center(
                    //               child:
                    //                   Text(getTranslated(context, 'noItem')!));
                    //     },
                    //     selector: (_, categoryProvider) =>
                    //         categoryProvider.subList,
                    //   ),
                    // ),
                  ],
                )
              : Container();
        },
      ),
    );
  }
  _catList() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? Container(
            width: double.infinity,
            child: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.simmerBase,
                highlightColor: Theme.of(context).colorScheme.simmerHigh,
                child: catLoading()))
            : Container(
            height: MediaQuery.of(context).size.height/1,
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount:  catList.length < 10 ? catList.length : 10,
              scrollDirection: Axis.vertical,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount
                (crossAxisCount: 3,mainAxisSpacing: 10), itemBuilder: (context, index) {
              if (catList.isEmpty)
                return  Center(
                    child:
                    Text(getTranslated(context, 'noItem')!));
              else
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10),
                  child: GestureDetector(
                    onTap: () async {
                      if (catList[index].subList == null ||
                          catList[index].subList!.length == 0) {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductList(
                                name: catList[index].name,
                                id: catList[index].id,
                                tag: false,
                                fromSeller: false,
                              ),
                            ));
                      } else {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubCategory(
                                title: catList[index].name!,
                                subList: catList[index].subList,
                                catId: catList[index].id,
                              ),
                            ));
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                                bottom: 5.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: new FadeInImage(
                                fadeInDuration: Duration(milliseconds: 150),
                                image: CachedNetworkImageProvider(
                                  catList[index].image!,
                                ),
                                height: 100.0,
                                // width: 100.0,
                                fit: BoxFit.fill,
                                imageErrorBuilder:
                                    (context, error, stackTrace) =>
                                    erroWidget(50),
                                placeholder: placeHolder(50),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            child: Text(
                              catList[index].name!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

            },)
        );
      },
      selector: (_, homeProvider) => homeProvider.catLoading,
    );
  }

  Widget catLoading() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                    .map((_) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.white,
                    shape: BoxShape.circle,
                  ),
                  width: 50.0,
                  height: 50.0,
                ))
                    .toList()),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ),
      ],
    );
  }

  Widget catItem(int index, BuildContext context1) {
    return Selector<CategoryProvider, int>(
      builder: (context, data, child) {
        if (index == 0 && (popularList.length > 0)) {
          return GestureDetector(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: data == index
                      ? Theme.of(context).colorScheme.white
                      : Colors.transparent,
                  border: data == index
                      ? Border(
                          left: BorderSide(width: 5.0, color: colors.primary),
                        )
                      : null
                  // borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: SvgPicture.asset(
                        data == index
                            ? imagePath + "popular_sel.svg"
                            : imagePath + "popular.svg",
                        color: colors.primary,
                      ),
                    ),
                  ),
                  Text(
                    catList[index].name! + "\n",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context1).textTheme.caption!.copyWith(
                        color: data == index
                            ? colors.primary
                            : Theme.of(context).colorScheme.fontColor),
                  )
                ],
              ),
            ),
            onTap: () {
              context1.read<CategoryProvider>().setCurSelected(index);
              context1.read<CategoryProvider>().setSubList(popularList);
            },
          );
        } else {
          return GestureDetector(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: data == index
                      ? Theme.of(context).colorScheme.white
                      : Colors.transparent,
                  border: data == index
                      ? Border(
                          left: BorderSide(width: 5.0, color: colors.primary),
                        )
                      : null),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: FadeInImage(
                            image: CachedNetworkImageProvider(
                                catList[index].image!),
                            fadeInDuration: Duration(milliseconds: 150),
                            fit: BoxFit.contain,
                            imageErrorBuilder: (context, error, stackTrace) =>
                                erroWidget(50),
                            placeholder: placeHolder(50),
                          )),
                    ),
                  ),
                  Text(
                    catList[index].name! + "\n",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context1).textTheme.caption!.copyWith(
                        color: data == index
                            ? colors.primary
                            : Theme.of(context).colorScheme.fontColor),
                  )
                ],
              ),
            ),
            onTap: () {
              context1.read<CategoryProvider>().setCurSelected(index);
              if (catList[index].subList == null ||
                  catList[index].subList!.length == 0) {
                print("kjhasdashjkdkashjdksahdsahdk");
                context1.read<CategoryProvider>().setSubList([]);
                Navigator.push(
                    context1,
                    MaterialPageRoute(
                      builder: (context) => ProductList(
                        name: catList[index].name,
                        id: catList[index].id,
                        tag: false,
                        fromSeller: false,
                      ),
                    ));
              } else {
                context1
                    .read<CategoryProvider>()
                    .setSubList(catList[index].subList);
              }
            },
          );
        }
      },
      selector: (_, cat) => cat.curCat,
    );
  }

  subCatItem(List<Product> subList, int index, BuildContext context) {
    return GestureDetector(
      child: Column(
        children: <Widget>[
          Expanded(
              child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                      fit: BoxFit.contain,
                      image: NetworkImage('${subList[index].image!}'))),
              // child: FadeInImage(
              //   image: CachedNetworkImageProvider(subList[index].image!),
              //   fadeInDuration: Duration(milliseconds: 150),
              //   fit: BoxFit.cover,
              //   imageErrorBuilder: (context, error, stackTrace) =>
              //       erroWidget(50),
              //   placeholder: placeHolder(50),
              // ),
            ),
          )),
          Text(
            subList[index].name! + "\n",
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
          )
        ],
      ),
      onTap: () {
        if (context.read<CategoryProvider>().curCat == 0 &&
            popularList.length > 0) {
          if (popularList[index].subList == null ||
              popularList[index].subList!.length == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductList(
                    name: popularList[index].name,
                    id: popularList[index].id,
                    tag: false,
                    fromSeller: false,
                  ),
                ));
          } else {

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubCategory(
                    subList: popularList[index].subList,
                    title: popularList[index].name ?? "",
                    catId: popularList[index].id,
                  ),
                ));
          }
        } else if (subList[index].subList == null ||
            subList[index].subList!.length == 0) {
          print(StackTrace.current);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductList(
                  name: subList[index].name,
                  id: subList[index].id,
                  tag: false,
                  fromSeller: false,
                ),
              ));
        } else {
          print(StackTrace.current);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubCategory(
                  subList: subList[index].subList,
                  title: subList[index].name ?? "",
                ),
              ));
        }
      },
    );
  }
}
