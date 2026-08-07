plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Build da adquirente STONE. E uma COPIA de android/ com o SDK da Stone
// embarcado: a pasta e trocada manualmente com android/ antes de gerar este
// build (SDKs de adquirente sao proprietarios e nao coexistem bem no mesmo
// binario). Tudo que mudar em android/ precisa ser refletido aqui.
android {
    namespace = "br.com.constel.constel_pay"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // IDENTICO ao da build generica: se divergir, instalar a build Stone
        // por cima vira app novo em vez de atualizacao.
        applicationId = "br.com.constel.constel_pay"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // O SDK da Stone e as dependencias de impressao estouram o limite de
        // 64k metodos.
        multiDexEnabled = true
    }

    signingConfigs {
        // ATENCAO (divida conhecida, registrada no README): os arquivos
        // .properties da Gertec e da Positivo sao keystores JKS binarios
        // renomeados para escapar do `**/*.jks` do .gitignore. Os dois tem o
        // mesmo conteudo, ou seja, o flavor Positivo assina com o certificado
        // Gertec. Serve para homologacao; precisa ser desfeito antes de
        // qualquer distribuicao por loja de fabricante.
        create("gertec") {
            storeFile = file("../certificado/gertec.jks")
            storePassword = "Development@GertecDeveloper2018"
            keyAlias = "developmentgertecdeveloper_enhancedapp"
            keyPassword = "Development@GertecDeveloper2018"
        }
        create("positivo") {
            storeFile = file("../certificado/positivo/positivo-keystore.properties")
            storePassword = "Development@GertecDeveloper2018"
            keyAlias = "developmentgertecdeveloper_enhancedapp"
            keyPassword = "Development@GertecDeveloper2018"
        }
    }

    // Um APK por modelo de maquininha, como a homologacao da Stone exige.
    // Esta dimensao e por HARDWARE, nao por adquirente: a adquirente continua
    // sendo decidida pela troca de pasta.
    flavorDimensions += "maquininha"

    productFlavors {
        create("dev") {
            dimension = "maquininha"
            versionNameSuffix = "-stone-dev"
            signingConfig = signingConfigs.getByName("debug")
        }
        create("sunmi") {
            dimension = "maquininha"
            versionNameSuffix = "-stone-sunmi"
            signingConfig = signingConfigs.getByName("debug")
        }
        create("sunmiSeriesP") {
            dimension = "maquininha"
            versionNameSuffix = "-stone-sunmiSeriesP"
            signingConfig = signingConfigs.getByName("debug")
        }
        create("ingenico") {
            dimension = "maquininha"
            versionNameSuffix = "-stone-ingenico"
            signingConfig = signingConfigs.getByName("debug")
        }
        create("gertecGpos700") {
            dimension = "maquininha"
            versionNameSuffix = "-stone-gertecGpos700"
            signingConfig = signingConfigs.getByName("gertec")
        }
        create("gertecGpos760") {
            dimension = "maquininha"
            versionNameSuffix = "-stone-gertecGpos760"
            signingConfig = signingConfigs.getByName("gertec")
        }
        create("tectoySeriesT") {
            dimension = "maquininha"
            versionNameSuffix = "-stone-tectoySeriesT"
            signingConfig = signingConfigs.getByName("debug")
        }
        create("positivoSeriesL") {
            dimension = "maquininha"
            versionNameSuffix = "-stone-positivoSeriesL"
            signingConfig = signingConfigs.getByName("positivo")
        }
    }

    buildTypes {
        release {
            // A assinatura real vem do flavor (cada fabricante exige a sua);
            // os flavors sem certificado proprio caem na chave de debug para
            // que `flutter run --release` continue funcionando.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    packaging {
        // O SDK da Stone traz varios META-INF conflitantes entre artefatos.
        resources.excludes += setOf("META-INF/LICENSE", "META-INF/NOTICE", "META-INF/*")
    }

    configurations.all {
        // Conflita com o XML parser do Android.
        exclude(group = "xpp3", module = "xpp3_min")
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // SDK da Stone: o nucleo mais o suporte de cada familia de maquininha.
    // Todos entram no mesmo APK; quem resolve o hardware em runtime e o SDK.
    implementation("br.com.stone:stone-sdk:4.15.0")
    implementation("br.com.stone:stone-sdk-posandroid:4.15.0")
    implementation("br.com.stone:stone-sdk-posandroid-ingenico:4.15.0")
    implementation("br.com.stone:stone-sdk-posandroid-gertec:4.15.0")
    implementation("br.com.stone:stone-sdk-posandroid-sunmi:4.15.0")
    implementation("com.github.tony19:logback-android:2.0.0")
    implementation("androidx.multidex:multidex:2.0.1")
}