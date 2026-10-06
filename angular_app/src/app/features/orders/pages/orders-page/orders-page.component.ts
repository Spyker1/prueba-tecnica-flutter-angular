import {
  Component,
  OnInit,
  inject,
  signal,
  computed,
  DestroyRef
} from '@angular/core';
import { CurrencyPipe } from '@angular/common';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { OrdersService } from '../../../../core/services/orders.service';
import { CartOrder } from '../../../../core/models/order.model';
import { OrderCardComponent } from '../../components/order-card/order-card.component';

@Component({
  selector: 'app-orders-page',
  standalone: true,
  imports: [CurrencyPipe, OrderCardComponent],
  templateUrl: './orders-page.component.html',
  styleUrl: './orders-page.component.css'
})
export class OrdersPageComponent implements OnInit {
  private readonly ordersService = inject(OrdersService);
  private readonly destroyRef = inject(DestroyRef);

  // Estados reactivos basados en Signals
  readonly orders = signal<CartOrder[]>([]);
  readonly loading = signal<boolean>(true);
  readonly errorMessage = signal<string | null>(null);
  readonly minTotalFilter = signal<number>(0);
  readonly selectedOrder = signal<CartOrder | null>(null);

  // Filtro reactivo derivado que recalcula la lista según el monto mínimo
  readonly filteredOrders = computed(() => {
    const min = this.minTotalFilter();
    return this.orders().filter((order) => order.discountedTotal >= min);
  });

  // Estadísticas derivadas
  readonly totalOrdersCount = computed(() => this.orders().length);
  readonly filteredOrdersCount = computed(() => this.filteredOrders().length);

  ngOnInit(): void {
    this.loadOrders();
  }

  loadOrders(): void {
    this.loading.set(true);
    this.errorMessage.set(null);

    this.ordersService
      .getOrders()
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: (response) => {
          this.orders.set(response.carts);
          this.loading.set(false);
        },
        error: () => {
          this.errorMessage.set(
            'Error al cargar el listado de pedidos desde la API de DummyJSON.'
          );
          this.loading.set(false);
        }
      });
  }

  onMinTotalChange(event: Event): void {
    const target = event.target as HTMLInputElement;
    const value = parseFloat(target.value);
    this.minTotalFilter.set(isNaN(value) || value < 0 ? 0 : value);
  }

  resetFilter(): void {
    this.minTotalFilter.set(0);
  }

  onSelectOrder(order: CartOrder): void {
    this.selectedOrder.set(order);
  }

  closeDetail(): void {
    this.selectedOrder.set(null);
  }
}
