/// Model profil mahasiswa sesuai data UTS
class UserProfile {
  final String nama;
  final String nim;
  final String kelas;
  final String prodi;
  final String matakuliah;
  final String dosen;
  final String asisten;
  final String avatarUrl;
  final String githubUrl;

  const UserProfile({
    this.nama = 'Wayan Muizul Rozzak',
    this.nim = '2415051111',
    this.kelas = 'PTI 5A',
    this.prodi = 'Pendidikan Teknik Informatika',
    this.matakuliah = 'Pemrograman Mobile',
    this.dosen = 'Dr. Ir. I Ketut Resika Arthana, S.T., M.Kom',
    this.asisten = 'Made Yuda Sadewa, S.Pd.',
    this.avatarUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
    this.githubUrl = 'https://github.com/wayanrozzak/uts_pemrog',
  });
}
