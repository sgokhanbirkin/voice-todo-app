# 🚀 Voice Todo App - Kurulum Rehberi

Bu dosya, Voice Todo App projesini sıfırdan kurmanız için detaylı adımları içerir.

## 📋 Ön Gereksinimler

### Sistem Gereksinimleri

- **İşletim Sistemi**: Windows 10+, macOS 10.15+, Ubuntu 18.04+
- **RAM**: En az 8GB (16GB önerilen)
- **Disk Alanı**: En az 10GB boş alan
- **Internet**: Kurulum sırasında gerekli

### Yazılım Gereksinimleri

- **Flutter SDK**: 3.19.0 veya üzeri
- **Dart**: 3.3.0 veya üzeri
- **Git**: 2.20.0 veya üzeri
- **IDE**: Android Studio, VS Code veya IntelliJ IDEA

## 🔧 Flutter Kurulumu

### 1. Flutter SDK İndirin

```bash
# macOS/Linux
cd ~/development
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.19.0-stable.tar.xz
tar xf flutter_macos_3.19.0-stable.tar.xz

# Windows
# https://docs.flutter.dev/get-started/install/windows adresinden indirin
```

### 2. PATH'e Ekleyin

```bash
# macOS/Linux (.zshrc veya .bashrc)
export PATH="$PATH:$HOME/development/flutter/bin"

# Windows
# Sistem Özellikleri > Ortam Değişkenleri > Path'e ekleyin
```

### 3. Kurulumu Doğrulayın

```bash
flutter doctor
```

Tüm ✓ işaretlerini görmelisiniz. Eksik olanları kurun.

## 📱 Platform Kurulumları

### Android

1. **Android Studio** kurun
2. **Android SDK** kurun
3. **Android Emulator** oluşturun
4. **Flutter doctor** ile doğrulayın

```bash
flutter doctor --android-licenses
flutter doctor
```

### iOS (macOS)

1. **Xcode** kurun (App Store'dan)
2. **Xcode Command Line Tools** kurun
3. **iOS Simulator** kurun
4. **Flutter doctor** ile doğrulayın

```bash
sudo xcode-select --install
flutter doctor
```

### Web

```bash
flutter config --enable-web
flutter doctor
```

## 🗄️ Supabase Kurulumu

### 1. Supabase Hesabı Oluşturun

1. [https://supabase.com](https://supabase.com) gidin
2. **Sign Up** ile hesap oluşturun
3. Email doğrulamasını tamamlayın

### 2. Yeni Proje Oluşturun

1. **New Project** butonuna tıklayın
2. **Organization** seçin (yoksa oluşturun)
3. **Project name**: `voice-todo-app`
4. **Database password**: Güçlü bir şifre belirleyin
5. **Region**: Size en yakın bölgeyi seçin
6. **Create new project** butonuna tıklayın

### 3. API Bilgilerini Alın

1. **Settings** > **API** bölümüne gidin
2. **Project URL**'i kopyalayın
3. **anon public** key'i kopyalayın

### 4. Veritabanı Şemasını Oluşturun

**SQL Editor**'da aşağıdaki komutları çalıştırın:

```sql
-- Tasks tablosu
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  priority TEXT CHECK (priority IN ('low', 'medium', 'high')),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'cancelled')),
  due_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Audio files tablosu
CREATE TABLE audio_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  file_size BIGINT,
  duration INTEGER,
  format TEXT,
  recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Row Level Security (RLS) aktifleştirin
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE audio_files ENABLE ROW LEVEL SECURITY;

-- RLS policies oluşturun
CREATE POLICY "Users can view own tasks" ON tasks
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own audio files" ON audio_files
  FOR ALL USING (auth.uid() = (SELECT user_id FROM tasks WHERE id = audio_files.task_id));
```

### 5. Storage Bucket Oluşturun

1. **Storage** > **Buckets** bölümüne gidin
2. **New bucket** butonuna tıklayın
3. **Name**: `audio-files`
4. **Public bucket**: `false`
5. **File size limit**: `50MB`
6. **Allowed MIME types**: `audio/*`
7. **Create bucket** butonuna tıklayın

### 6. Storage Policies Oluşturun

```sql
-- Storage policies
CREATE POLICY "Users can upload own audio files" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'audio-files' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can view own audio files" ON storage.objects
  FOR SELECT USING (bucket_id = 'audio-files' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can update own audio files" ON storage.objects
  FOR UPDATE USING (bucket_id = 'audio-files' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete own audio files" ON storage.objects
  FOR DELETE USING (bucket_id = 'audio-files' AND auth.uid()::text = (storage.foldername(name))[1]);
```

## 🚀 Proje Kurulumu

### 1. Repository'yi Klonlayın

```bash
git clone https://github.com/yourusername/voice-todo-app.git
cd voice-todo-app
```

### 2. Dependencies'leri Yükleyin

```bash
flutter pub get
```

### 3. Environment Dosyasını Oluşturun

```bash
# .env dosyası oluşturun
touch .env
```

### 4. .env Dosyasını Doldurun

```env
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here

# App Configuration
APP_NAME=Voice Todo
APP_VERSION=1.0.0
APP_ENVIRONMENT=development

# Audio Configuration
AUDIO_QUALITY=high
MAX_RECORDING_DURATION=300
AUDIO_FORMAT=m4a

# Sync Configuration
SYNC_INTERVAL=30000
MAX_RETRY_ATTEMPTS=3
```

### 5. iOS için Pod Install (macOS)

```bash
cd ios
pod install
cd ..
```

### 6. Android için Gradle Sync

```bash
cd android
./gradlew clean
cd ..
```

## 🧪 Test ve Doğrulama

### 1. Flutter Doctor

```bash
flutter doctor
```

### 2. Dependencies Check

```bash
flutter pub deps
```

### 3. Build Test

```bash
# Android
flutter build apk --debug

# iOS
flutter build ios --debug

# Web
flutter build web --debug
```

### 4. Run Test

```bash
# Android Emulator
flutter run

# iOS Simulator
flutter run -d ios

# Web
flutter run -d chrome
```

## 🔐 İlk Kullanıcı Oluşturma

### 1. Uygulamayı Çalıştırın

```bash
flutter run
```

### 2. Kayıt Olun

1. **Register** butonuna tıklayın
2. Email ve şifre girin
3. **Create Account** butonuna tıklayın
4. Email doğrulamasını tamamlayın

### 3. Giriş Yapın

1. **Login** butonuna tıklayın
2. Email ve şifre girin
3. **Sign In** butonuna tıklayın

## 🐛 Sorun Giderme

### Flutter Doctor Hataları

```bash
# Flutter'ı güncelleyin
flutter upgrade

# Cache'i temizleyin
flutter clean
flutter pub get

# Doctor'ı tekrar çalıştırın
flutter doctor
```

### Supabase Bağlantı Hataları

1. `.env` dosyasındaki bilgileri kontrol edin
2. Supabase projesinin aktif olduğundan emin olun
3. Internet bağlantınızı kontrol edin
4. Firewall ayarlarını kontrol edin

### Build Hataları

```bash
# Clean build
flutter clean
flutter pub get

# Platform-specific clean
cd android && ./gradlew clean && cd ..
cd ios && pod install && cd ..

# Tekrar deneyin
flutter run
```

### Permission Hataları

1. **Android**: `android/app/src/main/AndroidManifest.xml`'de permissions'ları kontrol edin
2. **iOS**: `ios/Runner/Info.plist`'de permission descriptions'ları kontrol edin

## 📱 Platform-Specific Kurulumlar

### Android

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS

```xml
<!-- ios/Runner/Info.plist -->
<key>NSMicrophoneUsageDescription</key>
<string>Bu uygulama sesli görev kaydetmek için mikrofon erişimi gerektirir.</string>
<key>NSCameraUsageDescription</key>
<string>Bu uygulama fotoğraf çekmek için kamera erişimi gerektirir.</string>
```

## 🚀 Production Deployment

### 1. Release Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### 2. App Signing

- **Android**: Keystore oluşturun ve `key.properties` yapılandırın
- **iOS**: Apple Developer hesabı ve sertifikalar gerekli

### 3. Store Submission

- **Google Play Store**: APK veya AAB yükleyin
- **App Store**: Xcode ile archive ve upload yapın

## 📚 Ek Kaynaklar

- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [GetX Documentation](https://pub.dev/packages/get)
- [Hive Documentation](https://docs.hivedb.dev/)

## 🤝 Yardım

Kurulum sırasında sorun yaşıyorsanız:

1. [GitHub Issues](https://github.com/yourusername/voice-todo-app/issues) açın
2. Detaylı hata mesajını paylaşın
3. Kullandığınız işletim sistemini belirtin
4. Flutter ve Dart versiyonlarını belirtin

---

**Başarılı kurulum!** 🎉

Artık Voice Todo App'i kullanmaya başlayabilirsiniz. Herhangi bir sorun yaşarsanız yukarıdaki kaynakları kontrol edin.
