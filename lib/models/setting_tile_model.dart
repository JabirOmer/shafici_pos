class SettingTileModel {
  final String icon;
  final String title;
  final String? value;
  final bool? toggleValue;
  final bool toggleIsLoading;
  final void Function()? onClick;

  SettingTileModel({
    required this.icon,
    required this.title,
    this.value,
    this.toggleValue,
    this.toggleIsLoading = false,
    this.onClick
  });
}