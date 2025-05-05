class ProfileModel {
  final int memberId;
  final String namaDepan;
  final String namaBelakang;
  final String tanggalLahir;
  final int accountIdFk;
  final String email;

  ProfileModel({
    required this.memberId,
    required this.namaDepan,
    required this.namaBelakang,
    required this.tanggalLahir,
    required this.accountIdFk,
    required this.email,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      memberId: json['member_id'],
      namaDepan: json['nama_depan'],
      namaBelakang: json['nama_belakang'],
      tanggalLahir: json['tanggal_lahir'],
      accountIdFk: json['account_id_fk'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_depan': namaDepan,
      'nama_belakang': namaBelakang,
      'tanggal_lahir': tanggalLahir,
      'email': email,
    };
  }
}
