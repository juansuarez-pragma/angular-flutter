import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideAnimations } from '@angular/platform-browser/animations';

/**
 * Configuración de la aplicación Angular standalone
 */
export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter([]),
    provideAnimations()
  ]
};
