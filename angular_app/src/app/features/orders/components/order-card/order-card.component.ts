import { Component, ChangeDetectionStrategy, input, output, inject } from '@angular/core';
import { CurrencyPipe } from '@angular/common';
import { Router } from '@angular/router';
import { CartOrder } from '../../../../core/models/order.model';
import { DiscountPipe } from '../../../../core/pipes/discount.pipe';

@Component({
  selector: 'app-order-card',
  standalone: true,
  imports: [CurrencyPipe, DiscountPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './order-card.component.html',
  styleUrl: './order-card.component.css'
})
export class OrderCardComponent {
  private readonly router = inject(Router);

  readonly order = input.required<CartOrder>();
  readonly viewDetail = output<CartOrder>();

  onViewDetail(): void {
    this.viewDetail.emit(this.order());
    this.router.navigate(['/orders', this.order().id]);
  }
}
