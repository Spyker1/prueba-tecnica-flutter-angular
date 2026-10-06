import { Component, ChangeDetectionStrategy, input, output } from '@angular/core';
import { CurrencyPipe } from '@angular/common';
import { CartOrder } from '../../../../core/models/order.model';

@Component({
  selector: 'app-order-card',
  standalone: true,
  imports: [CurrencyPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './order-card.component.html',
  styleUrl: './order-card.component.css'
})
export class OrderCardComponent {
  readonly order = input.required<CartOrder>();
  readonly viewDetail = output<CartOrder>();

  onViewDetail(): void {
    this.viewDetail.emit(this.order());
  }
}
