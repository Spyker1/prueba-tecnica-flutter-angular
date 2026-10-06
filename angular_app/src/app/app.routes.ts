import { Routes } from '@angular/router';
import { OrdersPageComponent } from './features/orders/pages/orders-page/orders-page.component';

export const routes: Routes = [
  {
    path: '',
    component: OrdersPageComponent,
    title: 'Panel de Pedidos | DummyJSON'
  },
  {
    path: 'orders/:id',
    loadComponent: () =>
      import(
        './features/orders/pages/order-detail-page/order-detail-page.component'
      ).then((m) => m.OrderDetailPageComponent),
    title: 'Detalle del Pedido | DummyJSON'
  },
  {
    path: '**',
    redirectTo: ''
  }
];
