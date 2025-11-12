import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { appConfig } from './app/app.config';

/**
 * Bootstrap de la aplicación Angular MFE
 */
bootstrapApplication(AppComponent, appConfig)
  .then(() => {
    console.log('🚀 Angular MFE UI iniciado correctamente');
  })
  .catch((err) => {
    console.error('❌ Error iniciando Angular MFE:', err);
  });
