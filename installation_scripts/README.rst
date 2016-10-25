=================================================================
================ OPENSTACK INSTALLATION SCRIPTS =================
=================================================================

Güncel scriptler Mitaka versiyonu kurulumu yapmaktadır.


Kuruluma başlanmadan önce

1. Network ayarları
   Management network ve Provider network IPleri atanmış olmalıdır.

2. /etc/hosts dosyası
   /etc/hosts dosyasından 127.0.1.1 satırı yoruma alınmalıdır.
   Belirlenen Management IP controller nodun adıyla /etc/hosts dosyasına eklenmiş olmalıdır

3. conf.sh
   conf.sh dosyası kurulum için hazırlanmalıdır.

4. root
   Kurulum adımları root kullanıcısı ile uygulanmalıdır.


========================================================================
========================== BİLİNEN DURUMLAR ============================
========================================================================

Ceilometer kurulumunda mongo db kullanıcı oluşturmada hata var. Bu durumda kurulum sonunda mongo db kullanıcısı manuel oluşturulup ceilometer servisleri yeniden başlatılmalıdır.

Live Migration uyumlu bir ortama kurulum yapılıyorsa ayrıca shared storage ayarları ve ssh bağlantı ayarları yapılmalıdır.
Bir bug sebebiyle kurulumdan sonra compute nodlarda /var/lib/nova/instances dizini ceilometer kullanıcısına ait görünebilir. Bu durumda alınan "Permission denied." hatasını gidermek için aşağıdaki adımın tek bir compute nodda uygulanması yeterlidir.

# chown nova:nova /var/lib/nova/instances




