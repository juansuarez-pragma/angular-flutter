import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { BridgeService } from './services/bridge.service';
import { Subject, takeUntil } from 'rxjs';

/**
 * Componente principal del MFE de Angular
 *
 * Este componente es una "vista tonta" que:
 * - Muestra la UI
 * - Delega toda la lógica al Shell de Flutter vía BridgeService
 * - NO contiene lógica de negocio
 * - NO maneja estado complejo
 * - NO hace llamadas a APIs
 */
@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit, OnDestroy {
  // Estado de la UI
  userName: string = 'Cargando...';
  newNameInput: string = '';
  isRunningInFlutter: boolean = false;

  // Para limpieza de subscripciones
  private destroy$ = new Subject<void>();

  constructor(private bridgeService: BridgeService) {}

  ngOnInit(): void {
    console.log('Angular: AppComponent inicializado');

    // Verificar si está corriendo en Flutter
    this.isRunningInFlutter = this.bridgeService.isRunningInFlutter();
    console.log('Angular: Ejecutando en Flutter:', this.isRunningInFlutter);

    // Subscribirse a actualizaciones de userName desde Flutter
    this.bridgeService.userName$
      .pipe(takeUntil(this.destroy$))
      .subscribe(userName => {
        console.log('Angular: Nombre de usuario actualizado:', userName);
        this.userName = userName;
      });
  }

  ngOnDestroy(): void {
    // Limpiar subscripciones
    this.destroy$.next();
    this.destroy$.complete();
  }

  /**
   * Maneja el clic en el botón de actualizar nombre
   */
  onUpdateNameClick(): void {
    if (!this.newNameInput.trim()) {
      alert('Por favor ingresa un nombre válido');
      return;
    }

    console.log('Angular: Usuario solicita actualizar nombre a:', this.newNameInput);
    this.bridgeService.updateName(this.newNameInput);
    this.newNameInput = '';
  }

  /**
   * Obtiene las iniciales del nombre de usuario
   */
  getInitials(name: string): string {
    if (!name || name === 'Cargando...') {
      return '...';
    }

    const words = name.trim().split(' ');

    if (words.length === 1) {
      return words[0].substring(0, 2).toUpperCase();
    }

    return (words[0].charAt(0) + words[words.length - 1].charAt(0)).toUpperCase();
  }
}
