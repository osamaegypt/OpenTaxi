library shared;

export 'src/constants/colors.dart';
export 'src/constants/values.dart';
export 'src/utils/enum_utils.dart';
export 'src/widgets/simple_widgets.dart';
export 'src/entities/car.dart';
export 'src/modules/trip_room/api.dart' hide TripRoomImplementation;
export 'src/widgets/map_widget.dart';
export 'src/utils/data_converters.dart';
// ----------------------- Exported Packages -------------------------- //
export 'package:flutter_svg/flutter_svg.dart';
export 'package:flutter_multi_formatter/flutter_multi_formatter.dart'
    hide enumFromString, enumToString;
export 'package:data_access/data_access.dart';
export 'package:web_socket_channel/web_socket_channel.dart';
export 'package:authentication/authentication.dart';
export 'package:location_manager/location_manager.dart';
export 'package:flutter_rating_bar/flutter_rating_bar.dart';
export 'package:google_fonts/google_fonts.dart';
