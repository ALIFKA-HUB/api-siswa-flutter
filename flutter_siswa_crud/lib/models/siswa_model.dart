class Siswa {
  final String? id;
  final String nama;
  final String kelas;
  final String nis;

  Siswa({
    this.id,
    required this.nama,
    required this.kelas,
    required this.nis,
  });

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      id: json['id']?.toString(),
      nama: json['nama']?.toString() ?? '',
      kelas: json['kelas']?.toString() ?? '',
      nis: json['nis']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': int.tryParse(id!) ?? id,
      'nama': nama,
      'kelas': kelas,
      'nis': nis,
    };
  }

  Siswa copyWith({
    String? id,
    String? nama,
    String? kelas,
    String? nis,
  }) {
    return Siswa(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      kelas: kelas ?? this.kelas,
      nis: nis ?? this.nis,
    );
  }

  @override
  String toString() => 'Siswa(id: $id, nama: $nama, kelas: $kelas, nis: $nis)';
}
