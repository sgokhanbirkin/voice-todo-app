# 🔧 Environment Variables - Voice Todo App

Bu dosya, Voice Todo App projesi için gerekli tüm environment variables'ları açıklar.

## 📁 .env Dosyası Oluşturma

Proje root dizininde `.env` dosyası oluşturun:

```bash
touch .env
```

## 🔑 Zorunlu Environment Variables

### Supabase Konfigürasyonu

| Değişken | Açıklama | Örnek |
|-----------|----------|-------|
| `SUPABASE_URL` | Supabase proje URL'i | `https://xyz.supabase.co` |
| `SUPABASE_ANON_KEY` | Public API anahtarı | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` |

**Nasıl Alınır:**
1. [Supabase Dashboard](https://app.supabase.com) gidin
2. Proje seçin
3. **Settings** > **API** bölümüne gidin
4. **Project URL** ve **anon public** key'i kopyalayın

## ⚙️ Opsiyonel Environment Variables

### Uygulama Konfigürasyonu

```env
# Uygulama adı
APP_NAME=Voice Todo

# Uygulama versiyonu
APP_VERSION=1.0.0

# Çalışma ortamı
APP_ENVIRONMENT=development
```

### Audio Konfigürasyonu

```env
# Ses kayıt kalitesi (low, medium, high)
AUDIO_QUALITY=high

# Maksimum kayıt süresi (saniye)
MAX_RECORDING_DURATION=300

# Ses dosya formatı (m4a, wav, mp3)
AUDIO_FORMAT=m4a
```

### Senkronizasyon Konfigürasyonu

```env
# Senkronizasyon aralığı (milisaniye)
SYNC_INTERVAL=30000

# Maksimum yeniden deneme sayısı
MAX_RETRY_ATTEMPTS=3
```

### Bildirim Konfigürasyonu

```env
# Bildirimler aktif mi?
NOTIFICATIONS_ENABLED=true

# Bildirim sesi aktif mi?
NOTIFICATION_SOUND_ENABLED=true
```

### Debug Konfigürasyonu (Sadece Development)

```env
# Debug modu aktif mi?
DEBUG_MODE=true

# Log seviyesi (debug, info, warning, error)
LOG_LEVEL=info
```

### Feature Flags

```env
# Biometric authentication aktif mi?
BIOMETRIC_AUTH_ENABLED=false

# Social login aktif mi?
SOCIAL_LOGIN_ENABLED=false

# Offline mode aktif mi?
OFFLINE_MODE_ENABLED=true
```

### Performans Konfigürasyonu

```env
# Cache boyutu (MB)
CACHE_SIZE_MB=100

# Auto-save aralığı (milisaniye)
AUTO_SAVE_INTERVAL=5000
```

### Güvenlik Konfigürasyonu

```env
# Session timeout süresi (milisaniye)
SESSION_TIMEOUT_MS=3600000

# Maksimum login deneme sayısı
MAX_LOGIN_ATTEMPTS=5
```

## 📋 Tam .env Örneği

```env
# =============================================================================
# Voice Todo App - Environment Variables
# =============================================================================

# SUPABASE CONFIGURATION (Zorunlu)
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlvdXItcHJvamVjdC1pZCIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNjM0NTY3ODkwLCJleHAiOjE5NTAxNDM4OTB9.example

# APP CONFIGURATION
APP_NAME=Voice Todo
APP_VERSION=1.0.0
APP_ENVIRONMENT=development

# AUDIO CONFIGURATION
AUDIO_QUALITY=high
MAX_RECORDING_DURATION=300
AUDIO_FORMAT=m4a

# SYNC CONFIGURATION
SYNC_INTERVAL=30000
MAX_RETRY_ATTEMPTS=3

# NOTIFICATION CONFIGURATION
NOTIFICATIONS_ENABLED=true
NOTIFICATION_SOUND_ENABLED=true

# DEBUG CONFIGURATION
DEBUG_MODE=true
LOG_LEVEL=info

# FEATURE FLAGS
BIOMETRIC_AUTH_ENABLED=false
SOCIAL_LOGIN_ENABLED=false
OFFLINE_MODE_ENABLED=true

# PERFORMANCE CONFIGURATION
CACHE_SIZE_MB=100
AUTO_SAVE_INTERVAL=5000

# SECURITY CONFIGURATION
SESSION_TIMEOUT_MS=3600000
MAX_LOGIN_ATTEMPTS=5
```

## 🚀 Kurulum Adımları

### 1. .env Dosyası Oluşturun

```bash
# Proje root dizininde
cp .env.example .env
# VEYA
touch .env
```

### 2. Supabase Bilgilerini Ekleyin

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

### 3. Diğer Değişkenleri Özelleştirin

İhtiyacınıza göre diğer environment variables'ları düzenleyin.

### 4. Uygulamayı Yeniden Başlatın

Environment variables'ları değiştirdikten sonra uygulamayı yeniden başlatın:

```bash
flutter clean
flutter pub get
flutter run
```

## 🔒 Güvenlik Notları

### ✅ Yapılması Gerekenler

- `.env` dosyasını `.gitignore`'a ekleyin
- Production'da hassas bilgileri güvenli şekilde saklayın
- Environment variables'ları düzenli olarak güncelleyin

### ❌ Yapılmaması Gerekenler

- `.env` dosyasını git'e commit etmeyin
- API key'leri public repository'de paylaşmayın
- Production credentials'ları development'ta kullanmayın

## 🐛 Sorun Giderme

### Environment Variables Çalışmıyor

1. `.env` dosyasının proje root'unda olduğundan emin olun
2. Dosya adının `.env` olduğundan emin olun (`.env.txt` değil)
3. Uygulamayı yeniden başlatın
4. `flutter clean` ve `flutter pub get` çalıştırın

### Supabase Bağlantı Hatası

1. `SUPABASE_URL` ve `SUPABASE_ANON_KEY` doğru mu?
2. Supabase projesi aktif mi?
3. Internet bağlantınız var mı?
4. Firewall ayarlarınız Supabase'i engelliyor mu?

## 📚 Ek Kaynaklar

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Environment Variables](https://docs.flutter.dev/deployment/environment-variables)
- [dotenv Package](https://pub.dev/packages/flutter_dotenv)

## 🤝 Yardım

Environment variables ile ilgili sorun yaşıyorsanız:

1. [GitHub Issues](https://github.com/yourusername/voice-todo-app/issues) açın
2. Detaylı hata mesajını paylaşın
3. Kullandığınız Flutter ve Dart versiyonunu belirtin
4. İşletim sisteminizi belirtin

---

**Not**: Bu dosya sürekli güncellenmektedir. En güncel bilgiler için GitHub repository'yi kontrol edin.
