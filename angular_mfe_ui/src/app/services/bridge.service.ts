import { Injectable } from '@angular/core';
import { Subject } from 'rxjs';

/**
 * Servicio de puente de comunicación entre Angular MFE y Flutter Shell
 *
 * Este servicio encapsula toda la lógica de comunicación bidireccional:
 * - Envía mensajes a Flutter vía window.AppBridge.postMessage
 * - Recibe eventos de Flutter vía document.addEventListener
 */
@Injectable({
  providedIn: 'root'
})
export class BridgeService {
  // Observable para notificar cambios
  public userName$ = new Subject<string>();

  constructor() {
    this.initializeListeners();
  }

  /**
   * Inicializa los listeners para eventos de Flutter
   */
  private initializeListeners(): void {
    // Listener para actualizaciones de datos desde Flutter
    document.addEventListener('flutterDataUpdate', ((event: CustomEvent) => {
      console.log('Angular: Evento flutterDataUpdate recibido', event.detail);

      if (event.detail && event.detail.userName) {
        this.userName$.next(event.detail.userName);
      }
    }) as EventListener);

    console.log('Angular: BridgeService listeners inicializados');
  }

  /**
   * Verifica si el AppBridge está disponible
   */
  private isAppBridgeAvailable(): boolean {
    return typeof (window as any).flutter_inappwebview !== 'undefined' &&
           typeof (window as any).flutter_inappwebview.callHandler === 'function';
  }

  /**
   * Envía un mensaje al Flutter Shell
   */
  private sendMessage(event: string, payload?: any): void {
    if (!this.isAppBridgeAvailable()) {
      console.warn('Angular: AppBridge no disponible (ejecutando fuera de Flutter)');
      return;
    }

    const message = {
      event,
      payload: payload || {}
    };

    try {
      (window as any).flutter_inappwebview.callHandler('AppBridge', message);
      console.log('Angular -> Flutter: Mensaje enviado', message);
    } catch (error) {
      console.error('Angular: Error enviando mensaje a Flutter', error);
    }
  }

  /**
   * Solicita actualizar el nombre en el Shell de Flutter
   */
  public updateName(newName: string): void {
    console.log('Angular: Solicitando actualización de nombre:', newName);
    this.sendMessage('UPDATE_NAME', { newName });
  }

  /**
   * Verifica si está corriendo dentro del WebView de Flutter
   */
  public isRunningInFlutter(): boolean {
    return this.isAppBridgeAvailable();
  }
}
