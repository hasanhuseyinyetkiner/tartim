enum OlcumTipi {
  normal(0, 'Normal Ağırlık'),
  suttenKesim(1, 'Sütten Kesim Ağırlığı'),
  yeniDogmus(2, 'Yeni Doğmuş Ağırlık');

  final int value;
  final String displayName;

  const OlcumTipi(this.value, this.displayName);

  static OlcumTipi fromValue(int value) {
    return OlcumTipi.values.firstWhere(
      (type) => type.value == value,
      orElse: () => OlcumTipi.normal,
    );
  }
}
