class AppStrings {
  final String langCode;

  const AppStrings(this.langCode);

  bool get _es => langCode == 'es';
  bool get _pt => langCode == 'pt';

  String _pick(String en, String es, String pt) {
    if (_es) return es;
    if (_pt) return pt;
    return en;
  }

  String get appName => 'RabbitX - Dark Sensi Panel';
  String get brandTitle => 'RABBITX';
  String get brandSub => 'Dark Sensi Panel';

  // Language screen
  String get language => _pick('Language', 'Idioma', 'Idioma');
  String get english => _pick('English', 'Inglés', 'Inglês');
  String get spanish => _pick('Spanish', 'Español', 'Espanhol');
  String get portuguese => _pick('Portuguese', 'Portugués', 'Português');
  String get next => _pick('Continue', 'Continuar', 'Continuar');
  String get finish => _pick('Done', 'Listo', 'Concluir');

  // Onboarding
  String get title1 =>
      _pick('Sensi Generator', 'Generador de Sensi', 'Gerador de Sensi');
  String get description1 => _pick(
        'Get the best sensi config for your device: custom DPI, fire button size and scope sensi tips in seconds.',
        'Obtén la mejor configuración de sensi para tu dispositivo: DPI personalizado, botón de disparo y miras en segundos.',
        'Obtenha a melhor configuração de sensi para seu dispositivo: DPI personalizada, botão de tiro e miras em segundos.',
      );
  String get title3 => _pick(
        'Live Performance Stats',
        'Estadísticas en Vivo',
        'Estatísticas em Tempo Real',
      );
  String get description3 => _pick(
        'Watch your game with live stats: FPS, ping, battery temp and screen refresh rate as you play.',
        'Controla tu juego con datos en vivo: FPS, ping, temperatura de batería y tasa de refresco mientras juegas.',
        'Acompanhe seu jogo com dados ao vivo: FPS, ping, temperatura da bateria e taxa de atualização enquanto joga.',
      );

  // Home header
  String get panelOn => _pick('PANEL ON', 'PANEL ON', 'PAINEL ON');
  String get panelOff => _pick('PANEL OFF', 'PANEL OFF', 'PAINEL OFF');
  String get appSettings => _pick('Settings', 'Ajustes', 'Configurações');

  // Sensi Tools section
  String get sectionSensi =>
      _pick('Sensi Tools', 'Herramientas Sensi', 'Ferramentas Sensi');
  String get sensitivityGenerator =>
      _pick('Sensi Generator', 'Generador de Sensi', 'Gerador de Sensi');
  String get featSensiDesc => _pick(
        'Pick your device and generate a sensi config tuned for it.',
        'Elige tu dispositivo y genera una sensi ajustada para él.',
        'Escolha seu dispositivo e gere uma sensi ajustada para ele.',
      );
  String get selectDevice =>
      _pick('Pick Device', 'Elegir Dispositivo', 'Escolher Dispositivo');
  String get mobile => _pick('Phone', 'Teléfono', 'Celular');
  String get emulator => _pick('Emulator', 'Emulador', 'Emulador');
  String get youtubers => 'YouTubers';
  String get generateSensi =>
      _pick('GENERATE SENSI', 'GENERAR SENSI', 'GERAR SENSI');
  String get sensiResult =>
      _pick('SENSI RESULT', 'RESULTADO SENSI', 'RESULTADO SENSI');
  String get scaleHint =>
      _pick('Scale 0 to 200', 'Escala 0 a 200', 'Escala 0 a 200');
  String get general => _pick('General', 'General', 'Geral');
  String get redDot => _pick('Red Dot', 'Punto Rojo', 'Ponto Vermelho');
  String get awm => 'AWM';

  String itemOf(int current, int total) =>
      _pick('$current of $total', '$current de $total', '$current de $total');

  String get featDpi => _pick(
        'DPI & Fire Button',
        'DPI y Botón de Disparo',
        'DPI e Botão de Tiro',
      );
  String get featDpiDesc => _pick(
        'Recommended DPI and fire button size from your last generated sensi.',
        'DPI y tamaño del botón de disparo recomendados de tu última sensi generada.',
        'DPI e tamanho do botão de tiro recomendados da sua última sensi gerada.',
      );
  String get dpi => 'DPI';
  String get buttonFire =>
      _pick('Fire Button', 'Botón de Disparo', 'Botão de Tiro');

  // Live Stats section
  String get realTimeStats =>
      _pick('Live Stats', 'Estadísticas en Vivo', 'Stats ao Vivo');
  String get proTag => 'PRO';
  String get featFps => _pick('FPS Meter', 'Medidor FPS', 'Medidor de FPS');
  String get featFpsDesc => _pick(
        'Shows the frames per second your screen is drawing right now.',
        'Muestra los cuadros por segundo que tu pantalla dibuja ahora.',
        'Mostra os quadros por segundo que sua tela está exibindo agora.',
      );
  String get featHz => _pick(
        'Screen Refresh Rate',
        'Tasa de Refresco',
        'Taxa de Atualização',
      );
  String get featHzDesc => _pick(
        'Shows the refresh rate your display is running at.',
        'Muestra los Hz a los que funciona tu pantalla.',
        'Mostra os Hz em que sua tela está funcionando.',
      );
  String get featPing => 'Ping';
  String get featPingDesc => _pick(
        'Measures your connection latency in milliseconds.',
        'Mide la latencia de tu conexión en milisegundos.',
        'Mede a latência da sua conexão em milissegundos.',
      );
  String get featBtemp => _pick(
        'Battery Temperature',
        'Temperatura de Batería',
        'Temperatura da Bateria',
      );
  String get featBtempDesc => _pick(
        'Tracks battery heat while you play.',
        'Controla el calor de la batería mientras juegas.',
        'Acompanha o calor da bateria enquanto você joga.',
      );

  // Pro Banner & Paywall
  String get unlockProFeatures => _pick(
        'GET PRO FEATURES',
        'OBTENER FUNCIONES PRO',
        'OBTER RECURSOS PRO',
      );
  String get proPerks => _pick(
        'Live Stats, No Ads',
        'Stats en Vivo, Sin Anuncios',
        'Stats ao Vivo, Sem Anúncios',
      );
  String get tryForFree =>
      _pick('Free trial', 'Prueba gratis', 'Teste grátis');
  String get paywallBrand => 'RABBITX PRO';
  String get paywallTitleTrial =>
      _pick('Try Pro free', 'Prueba Pro gratis', 'Teste Pro grátis');
  String paywallTitleDays(int days) =>
      _pick('for $days days', 'por $days días', 'por $days dias');
  String get paywallSubtitle => _pick(
        'Every tool unlocked. Zero ads. Cancel anytime.',
        'Todas las herramientas desbloqueadas. Cero anuncios. Cancela cuando quieras.',
        'Todas as ferramentas desbloqueadas. Zero anúncios. Cancele quando quiser.',
      );
  String get perksTitle =>
      _pick('Everything in Pro', 'Todo en Pro', 'Tudo no Pro');
  String get perkFps =>
      _pick('Live FPS meter', 'Medidor FPS en vivo', 'Medidor de FPS ao vivo');
  String get perkFpsDesc => _pick(
        'See your real frame rate while you play',
        'Ve tu tasa de cuadros real mientras juegas',
        'Veja sua taxa de quadros real enquanto joga',
      );
  String get perkPing =>
      _pick('Ping monitor', 'Monitor de ping', 'Monitor de ping');
  String get perkPingDesc => _pick(
        'Know your connection latency at a glance',
        'Conoce la latencia de tu conexión al instante',
        'Saiba a latência da sua conexão num relance',
      );
  String get perkHz => _pick(
        'Screen refresh rate',
        'Tasa de refresco',
        'Taxa de atualização',
      );
  String get perkHzDesc => _pick(
        'Check the Hz your display is running at',
        'Revisa los Hz en los que corre tu pantalla',
        'Verifique os Hz em que sua tela está rodando',
      );
  String get perkTemp => _pick(
        'Battery temperature',
        'Temperatura de batería',
        'Temperatura da bateria',
      );
  String get perkTempDesc => _pick(
        'Keep an eye on heat during long sessions',
        'Vigila el calor durante sesiones largas',
        'Fique de olho no calor em sessões longas',
      );
  String get perkSensi => _pick(
        'Instant sensi generation',
        'Generación instantánea de sensi',
        'Geração instantânea de sensi',
      );
  String get perkSensiDesc => _pick(
        'Unlimited generations, no ad breaks',
        'Generaciones ilimitadas, sin anuncios',
        'Gerações ilimitadas, sem anúncios',
      );
  String get perkNoAds => _pick('Zero ads', 'Cero anuncios', 'Zero anúncios');
  String get perkNoAdsDesc => _pick(
        'No pop-ups, no video ads, no waiting',
        'Sin ventanas emergentes, sin videos, sin esperas',
        'Sem pop-ups, sem vídeos, sem espera',
      );
  String get trialHow => _pick(
        'How your free trial works',
        'Cómo funciona tu prueba gratis',
        'Como funciona seu teste grátis',
      );
  String get trialToday => _pick('Today', 'Hoy', 'Hoje');
  String get trialTodayDesc => _pick(
        'Every Pro tool unlocks right away, free',
        'Todas las herramientas Pro se desbloquean al instante, gratis',
        'Todas as ferramentas Pro desbloqueiam agora, grátis',
      );
  String trialDay(int day) => _pick('Day $day', 'Día $day', 'Dia $day');
  String get trialEndDesc => _pick(
        'Trial ends. Cancel before then and you pay nothing',
        'Termina la prueba. Cancela antes y no pagas nada',
        'Fim do teste. Cancele antes e não pague nada',
      );
  String get trustTrial => _pick(
        'No charge today • Cancel anytime',
        'Sin cargos hoy • Cancela cuando quieras',
        'Sem cobrança hoje • Cancele quando quiser',
      );
  String get startFreeTrial => _pick(
        'BEGIN FREE TRIAL',
        'INICIAR PRUEBA GRATIS',
        'INICIAR TESTE GRÁTIS',
      );
  String paywallOpening(String storeName) => _pick(
        'OPENING ${storeName.toUpperCase()}…',
        'ABRIENDO ${storeName.toUpperCase()}…',
        'ABRINDO ${storeName.toUpperCase()}…',
      );
  String priceTrial(int days, String price) => _pick(
        '$days days free, then $price/month',
        '$days días gratis, luego $price/mes',
        '$days dias grátis, depois $price/mês',
      );
  String termsTrial(int days, String price, String storeName) => _pick(
        'After the $days-day free trial, your subscription renews automatically at $price per month until you cancel. Cancel anytime in $storeName.',
        'Tras la prueba gratuita de $days días, tu suscripción se renueva automáticamente a $price al mes hasta que canceles. Cancela cuando quieras en $storeName.',
        'Após o teste grátis de $days dias, sua assinatura renova automaticamente por $price por mês até cancelar. Cancele quando quiser na $storeName.',
      );
  String get termsDefault => _pick(
        'Subscription renews automatically after the 3-day trial. Cancel any time before it ends to avoid charges.',
        'La suscripción se renueva automáticamente tras la prueba de 3 días. Cancela antes para evitar cargos.',
        'A assinatura renova automaticamente após o teste de 3 dias. Cancele antes para evitar cobranças.',
      );
  String get subscriptionSuccess => _pick(
        'Premium is on! Enjoy every feature.',
        '¡Premium activado! Disfruta todas las funciones.',
        'Premium ativado! Aproveite todos os recursos.',
      );
  String get unlockFeature =>
      _pick('Unlock Now', 'Desbloquear ahora', 'Desbloquear agora');
  String get watchAdToUnlock => _pick(
        'View a short ad to unlock this',
        'Mira un anuncio corto para desbloquear esto',
        'Veja um anúncio curto para desbloquear',
      );
  String get watchAd => _pick('View Ad', 'Ver Anuncio', 'Ver Anúncio');
  String get cancel => _pick('Skip', 'Omitir', 'Pular');
  String get noAdsAvailable => _pick(
        'No ads ready now',
        'No hay anuncios disponibles ahora',
        'Nenhum anúncio disponível agora',
      );
  String get featureUnlocked =>
      _pick('Unlocked!', '¡Desbloqueado!', 'Desbloqueado!');
  String get restorePurchases => _pick(
        'Restore Purchases',
        'Restaurar compras',
        'Restaurar compras',
      );
  String get privacyPolicy => _pick(
        'Privacy Policy',
        'Política de privacidad',
        'Política de privacidade',
      );
  String get termsOfUse => _pick(
        'Terms of Use',
        'Términos de uso',
        'Termos de uso',
      );

  // Device Info section
  String get sectionDevice => _pick(
        'Device Info',
        'Info del Dispositivo',
        'Info do Dispositivo',
      );
  String get featDevice => _pick('Device', 'Dispositivo', 'Dispositivo');
  String get featDeviceDesc => _pick(
        'Model, brand and OS version of this device.',
        'Modelo, marca y versión del sistema.',
        'Modelo, marca e versão do sistema.',
      );
  String get featCpu => _pick('Processor', 'Procesador', 'Processador');
  String get featCpuDesc => _pick(
        'Chipset, core count and architecture.',
        'Chipset, núcleos y arquitectura.',
        'Chipset, núcleos e arquitetura.',
      );
  String get featRam => _pick('Memory (RAM)', 'Memoria (RAM)', 'Memória (RAM)');
  String get featRamDesc => _pick(
        'How much RAM is in use and how much is free.',
        'Cuánta RAM está en uso y cuánta está libre.',
        'Quanta RAM está em uso e quanta está livre.',
      );
  String get featStorage => _pick('Storage', 'Almacenamiento', 'Armazenamento');
  String get featStorageDesc => _pick(
        'Internal storage used and free space.',
        'Almacenamiento interno usado y espacio libre.',
        'Armazenamento interno usado e espaço livre.',
      );
  String get featDisplay => _pick('Display', 'Pantalla', 'Tela');
  String get featDisplayDesc => _pick(
        'Resolution, pixel density and screen size.',
        'Resolución, densidad de píxeles y tamaño de pantalla.',
        'Resolução, densidade de pixels e tamanho da tela.',
      );
  String get featBattery => _pick('Battery', 'Batería', 'Bateria');
  String get featBatteryDesc => _pick(
        'Charge level, status, health and voltage.',
        'Nivel de carga, estado, salud y voltaje.',
        'Nível de carga, status, saúde e voltagem.',
      );

  String get infoModel => _pick('Model', 'Modelo', 'Modelo');
  String get infoBrand => _pick('Brand', 'Marca', 'Marca');
  String get infoAndroid => _pick('OS', 'Sistema', 'Sistema');
  String get infoChipset => 'Chipset';
  String get infoCores => _pick('Cores', 'Núcleos', 'Núcleos');
  String get infoAbi => _pick('Architecture', 'Arquitectura', 'Arquitetura');
  String get infoUsed => _pick('Used', 'Usado', 'Usado');
  String get infoFree => _pick('Free', 'Libre', 'Livre');
  String get infoResolution => _pick('Resolution', 'Resolución', 'Resolução');
  String get infoDensity => _pick('Density', 'Densidad', 'Densidade');
  String get infoScreenSize =>
      _pick('Screen size', 'Tamaño de pantalla', 'Tamanho da tela');
  String get infoLevel => _pick('Level', 'Nivel', 'Nível');
  String get infoStatus => _pick('Status', 'Estado', 'Status');
  String get infoHealth => _pick('Health', 'Salud', 'Saúde');
  String get infoVoltage => _pick('Voltage', 'Voltaje', 'Voltagem');
  String get infoUnknown => _pick('Unknown', 'Desconocido', 'Desconhecido');

  String get batteryCharging => _pick('Charging', 'Cargando', 'Carregando');
  String get batteryDischarging =>
      _pick('Discharging', 'Descargando', 'Descarregando');
  String get batteryNotCharging =>
      _pick('Not charging', 'No cargando', 'Não carregando');
  String get batteryFull => _pick('Full', 'Completa', 'Cheia');
  String get batteryGood => _pick('Good', 'Buena', 'Boa');
  String get batteryOverheat =>
      _pick('Overheated', 'Sobrecalentada', 'Superaquecida');
  String get batteryDead => _pick('Dead', 'Dañada', 'Danificada');
  String get batteryCold => _pick('Cold', 'Fría', 'Fria');

  // Settings
  String get rateTheApp =>
      _pick('Rate App', 'Calificar App', 'Avaliar App');
  String get shareTheApp =>
      _pick('Share App', 'Compartir App', 'Compartilhar App');
  String versionLabel(String version) =>
      _pick('Version $version', 'Versión $version', 'Versão $version');

  // Rate Dialog
  String get enjoyingTheApp =>
      _pick('Like the app?', '¿Te gusta la app?', 'Gostando do app?');
  String get yourFeedbackHelps => _pick(
        'Your input helps us improve the app',
        'Tu opinión nos ayuda a mejorar la app',
        'Sua opinião nos ajuda a melhorar o app',
      );
  String get tapToRate => _pick(
        'Pick a star to rate',
        'Toca una estrella para calificar',
        'Toque uma estrela para avaliar',
      );
  String get later => _pick('Not now', 'Ahora no', 'Agora não');
  String get rateNow => _pick('Rate it', 'Calificar', 'Avaliar');
  String get thankYouFeedback => _pick(
        'Thanks for the feedback!',
        '¡Gracias por tus comentarios!',
        'Obrigado pelo feedback!',
      );
  String get thankYouRating => _pick(
        'Thanks for rating!',
        '¡Gracias por calificarnos!',
        'Obrigado por avaliar!',
      );

  List<String> get ratingMessages => _pick(
        'Bad 😞|Okay 😐|Nice 🙂|Super! 😊|Perfect! 🤩',
        'Malo 😞|Regular 😐|Bien 🙂|¡Súper! 😊|¡Perfecto! 🤩',
        'Ruim 😞|Ok 😐|Bom 🙂|Ótimo! 😊|Perfeito! 🤩',
      ).split('|');
}
