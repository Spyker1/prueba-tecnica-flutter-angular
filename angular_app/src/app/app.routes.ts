import { Routes } from '@angular/router';
import { OrdersPageComponent } from './features/orders/pages/orders-page/orders-page.component';

export const routes: Routes = [
  {
    path: '',
    component: OrdersPageComponent,
    title: 'Panel de Pedidos | DummyJSON'
  },
  {
    path: '**',
    redirectTo: ''
  }
];
