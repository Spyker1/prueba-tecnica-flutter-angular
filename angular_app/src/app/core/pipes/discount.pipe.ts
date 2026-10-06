import { Pipe, PipeTransform } from '@angular/core';

export type DiscountFormat = 'percentage' | 'savings' | 'badge';

/**
 * Pipe standalone 'discount' que formatea descuentos de manera visual.
 * 
 * Soporta dos modos:
 * 1. Calculado: Recibe precio original y precio con descuento -> {{ total | discount:discountedTotal }}
 * 2. Porcentaje directo: Recibe el porcentaje directamente -> {{ discountPercentage | discount }}
 * 
 * Formatos disponibles:
 * - 'percentage' (default): Retorna "-X% OFF"
 * - 'savings': Retorna "Ahorro: $XX.XX"
 * - 'badge': Retorna "-X% OFF · Ahorro: $XX.XX"
 */
@Pipe({
  name: 'discount',
  standalone: true
})
export class DiscountPipe implements PipeTransform {
  transform(
    originalOrPercentage: number | null | undefined,
    discountedPrice?: number | null,
    format: DiscountFormat = 'percentage'
  ): string {
    if (originalOrPercentage == null || isNaN(originalOrPercentage)) {
      return '';
    }

    let percentage = 0;
    let savings = 0;

    if (discountedPrice !== undefined && discountedPrice !== null) {
      const original = originalOrPercentage;
      if (original <= 0) return '';
      savings = Math.max(0, original - discountedPrice);
      percentage = Math.round(((original - discountedPrice) / original) * 100);
    } else {
      // Se proveyó porcentaje directamente
      percentage = Math.round(originalOrPercentage);
    }

    if (percentage <= 0 && savings <= 0) {
      return '';
    }

    switch (format) {
      case 'savings':
        return `Ahorro: $${savings.toFixed(2)}`;
      case 'badge':
        return savings > 0
          ? `-${percentage}% OFF · Ahorro: $${savings.toFixed(2)}`
          : `-${percentage}% OFF`;
      case 'percentage':
      default:
        return `-${percentage}% OFF`;
    }
  }
}
