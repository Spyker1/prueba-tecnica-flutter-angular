import {
  Component,
  OnInit,
  ChangeDetectionStrategy,
  inject,
  signal,
  input,
  DestroyRef
} from '@angular/core';
import { CurrencyPipe } from '@angular/common';
import { RouterLink, ActivatedRoute } from '@angular/router';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { OrdersService } from '../../../../core/services/orders.service';
import { CartOrder } from '../../../../core/models/order.model';
import { DiscountPipe } from '../../../../core/pipes/discount.pipe';

@Component({
  selector: 'app-order-detail-page',
  standalone: true,
  imports: [CurrencyPipe, RouterLink, DiscountPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './order-detail-page.component.html',
  styleUrl: './order-detail-page.component.css'
})
export class OrderDetailPageComponent implements OnInit {
  private readonly ordersService = inject(OrdersService);
  private readonly route = inject(ActivatedRoute);
  private readonly destroyRef = inject(DestroyRef);

  // Soporte para withComponentInputBinding()
  readonly id = input<string>();

  readonly order = signal<CartOrder | null>(null);
  readonly loading = signal<boolean>(true);
  readonly errorMessage = signal<string | null>(null);

  ngOnInit(): void {
    const routeId = this.id() || this.route.snapshot.paramMap.get('id');
    if (routeId) {
      this.loadOrderDetail(routeId);
    } else {
      this.errorMessage.set('Identificador de pedido no válido.');
      this.loading.set(false);
    }
  }

  loadOrderDetail(orderId: string | number): void {
    this.loading.set(true);
    this.errorMessage.set(null);

    this.ordersService
      .getOrderById(orderId)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: (orderData) => {
          this.order.set(orderData);
          this.loading.set(false);
        },
        error: () => {
          this.errorMessage.set(
            `No se pudo cargar el detalle del pedido #${orderId}. Verifica la conexión o el ID.`
          );
          this.loading.set(false);
        }
      });
  }
}
