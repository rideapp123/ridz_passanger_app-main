import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';

import '../../stores/ui/ui_store.dart';
import '../../stores/users/user_store.dart';

final appProviders = <SingleChildWidget>[
  Provider<UIStore>(
    create: (_) => UIStore(),
  ),
  Provider<UserStore>(
    create: (_) => UserStore(),
  ),
  Provider<MapStore>(
    create: (_) => MapStore(),
    dispose: (_, store) => store.dispose(),
  ),
];
