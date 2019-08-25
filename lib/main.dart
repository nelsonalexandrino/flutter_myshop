import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import './providers/orders.dart';
import './providers/products_provider.dart';
import './providers/cart.dart';
import './providers/auth.dart';
import './screens/product_overview_screen.dart';
import './screens/product_details_screen.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_product_screen.dart';
import './screens/add_edit_product_screen.dart';
import './screens/auth-screen.dart';
import './screens/splash-screen.dart';
import 'helpers/custom_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          //builder: (context) => Orders(),
          value: AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, Products>(
          //builder: (context) => Products(),
          builder: (context, authProvider, previousProducts) => Products(
              authProvider.token,
              authProvider.userId,
              previousProducts == null ? [] : previousProducts.items),
        ),
        ChangeNotifierProvider.value(
          //builder: (context) => Cart(),
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, Orders>(
          //builder: (context) => Orders(),
          builder: (context, authProvider, previousOrders) => Orders(
              authProvider.token,
              authProvider.userId,
              previousOrders == null ? [] : previousOrders.orders),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authData, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: ThemeData(
              primarySwatch: Colors.teal,
              accentColor: Colors.tealAccent,
              fontFamily: 'Lato',
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustomPageTransationBuilder(),
                TargetPlatform.iOS: CustomPageTransationBuilder()
              })),
          home: authData.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  future: authData.tryAutoLogin(),
                  builder: (context, authSnapShot) =>
                      authSnapShot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductOverviewScreen.routeName: (context) =>
                ProductOverviewScreen(),
            ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrdersScreen.routeName: (context) => OrdersScreen(),
            UserProductsScreen.routeName: (context) => UserProductsScreen(),
            AddEditProductScreen.routeName: (context) => AddEditProductScreen(),
            AuthScreen.routeName: (context) => AuthScreen(),
          },
        ),
      ),
    );
  }
}
