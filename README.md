# 🎤 Voice Todo App

**Sesli komutlarla görev yönetimi yapan modern Flutter uygulaması**

[![Flutter](https://img.shields.io/badge/Flutter-3.19.0-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.3.0-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📖 Proje Hakkında

Voice Todo App, kullanıcıların sesli komutlarla görev oluşturabileceği, ses kayıtları ekleyebileceği ve gerçek zamanlı konuşma tanıma özelliklerine sahip modern bir görev yönetim uygulamasıdır.

### ✨ Özellikler

- 🎤 **Sesli Görev Oluşturma**: Mikrofon ile sesli görev kaydı
- 🎵 **Audio Recording**: Yüksek kaliteli ses kayıtları
- 🗣️ **Speech-to-Text**: Gerçek zamanlı konuşma tanıma
- 📱 **Responsive Design**: Mobil, tablet ve web uyumlu
- 🌐 **Multi-language**: Türkçe ve İngilizce dil desteği
- 🔄 **Offline-First**: Hive ile local storage
- ☁️ **Cloud Sync**: Supabase ile bulut senkronizasyonu
- 🎨 **Material 3**: Modern ve güzel UI tasarımı
- 🌙 **Dark/Light Theme**: Otomatik tema değişimi

## 🏗️ Mimari

Proje **Clean Architecture** prensiplerine göre yapılandırılmıştır:

```
lib/
├── core/                 # Genel yardımcılar, hata yönetimi
├── data/                 # Veri katmanı (Hive + Supabase)
├── features/             # Özellik modülleri
│   ├── auth/            # Kimlik doğrulama
│   ├── audio/           # Ses işlemleri
│   ├── todos/           # Görev yönetimi
│   └── settings/        # Ayarlar ve analitik
├── l10n/                # Çoklu dil desteği
└── product/             # Tema, responsive, widget'lar
```

### 🎯 Kullanılan Teknolojiler

- **State Management**: GetX
- **Navigation**: Go Router
- **Local Database**: Hive
- **Backend**: Supabase (PostgreSQL + Storage)
- **Audio**: record, just_audio, speech_to_text
- **UI**: Material 3, Responsive Design

## 🚀 Kurulum

### Gereksinimler

- Flutter SDK 3.19.0+
- Dart 3.3.0+
- Android Studio / VS Code
- iOS için Xcode (macOS)
- Git

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

Proje root dizininde `.env` dosyası oluşturun:

```bash
touch .env
```

### 4. .env Dosyasını Yapılandırın

`.env` dosyasına aşağıdaki değişkenleri ekleyin:

```env
# Supabase Configuration
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key

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

### 5. Supabase Projesini Kurun

1. [Supabase](https://supabase.com) hesabı oluşturun
2. Yeni proje oluşturun
3. Project Settings > API bölümünden URL ve ANON_KEY'i alın
4. `.env` dosyasına ekleyin

### 6. Uygulamayı Çalıştırın

```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## 🔧 Environment Değişkenleri Detayı

### Supabase Konfigürasyonu

| Değişken | Açıklama | Örnek |
|-----------|----------|-------|
| `SUPABASE_URL` | Supabase proje URL'i | `https://xyz.supabase.co` |
| `SUPABASE_ANON_KEY` | Public API anahtarı | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` |

### Uygulama Konfigürasyonu

| Değişken | Açıklama | Varsayılan |
|-----------|----------|------------|
| `APP_NAME` | Uygulama adı | Voice Todo |
| `APP_VERSION` | Uygulama versiyonu | 1.0.0 |
| `APP_ENVIRONMENT` | Çalışma ortamı | development |

### Audio Konfigürasyonu

| Değişken | Açıklama | Varsayılan |
|-----------|----------|------------|
| `AUDIO_QUALITY` | Ses kalitesi | high |
| `MAX_RECORDING_DURATION` | Maksimum kayıt süresi (saniye) | 300 |
| `AUDIO_FORMAT` | Ses dosya formatı | m4a |

### Senkronizasyon Konfigürasyonu

| Değişken | Açıklama | Varsayılan |
|-----------|----------|------------|
| `SYNC_INTERVAL` | Senkronizasyon aralığı (ms) | 30000 |
| `MAX_RETRY_ATTEMPTS` | Maksimum yeniden deneme | 3 |

## 📱 Kullanım

### Sesli Görev Oluşturma

1. Ana sayfada **"+"** butonuna tıklayın
2. Mikrofon butonuna basarak sesli kayıt başlatın
3. Görev detaylarını sesli olarak anlatın
4. Kayıt bitince **"Durdur"** butonuna basın
5. Görev başlığını ve açıklamasını düzenleyin
6. **"Kaydet"** butonuna tıklayın

### Ses Kayıtlarını Dinleme

1. Görev kartında **"Play"** butonuna tıklayın
2. Ses kaydı otomatik olarak başlayacak
3. **"Pause"** ile duraklatabilirsiniz
4. **"Stop"** ile durdurabilirsiniz

### Gerçek Zamanlı Konuşma Tanıma

1. **"Voice Commands"** sayfasına gidin
2. Mikrofon butonuna basarak konuşmaya başlayın
3. Konuşurken metin gerçek zamanlı olarak görünecek
4. Konuşma bitince **"Durdur"** butonuna basın

## 🗄️ Veritabanı Şeması

### Tasks Tablosu

```sql
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
```

### Audio Files Tablosu

```sql
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
```

## 🔐 Güvenlik

- **Authentication**: Supabase Auth ile güvenli giriş
- **Row Level Security**: Kullanıcı bazlı veri erişimi
- **File Storage**: Güvenli dosya yükleme ve indirme
- **API Keys**: Environment variables ile güvenli saklama

## 🧪 Test

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/
```

## 📦 Build

### Android APK

```bash
flutter build apk --release
```

### iOS IPA

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## 🚀 Deployment

### Supabase

1. Production environment'ı oluşturun
2. Environment variables'ları güncelleyin
3. Database migration'ları çalıştırın
4. Storage bucket'ları yapılandırın

### App Store / Play Store

1. Release build oluşturun
2. App signing yapılandırın
3. Store listing hazırlayın
4. Submit edin

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'feat: add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

### Commit Mesaj Formatı

```
feat: yeni özellik ekleme
fix: hata düzeltme
docs: dokümantasyon güncelleme
style: kod formatı düzenleme
refactor: kod refactoring
test: test ekleme/düzenleme
chore: yapılandırma değişiklikleri
```

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 📞 İletişim

- **Proje Sahibi**: [Your Name](https://github.com/yourusername)
- **Email**: your.email@example.com
- **Website**: [https://yourwebsite.com](https://yourwebsite.com)

## 🙏 Teşekkürler

- [Flutter Team](https://flutter.dev/) - Harika framework için
- [Supabase](https://supabase.com/) - Backend-as-a-Service için
- [GetX](https://pub.dev/packages/get) - State management için
- [Hive](https://pub.dev/packages/hive) - Local database için

---

⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!
