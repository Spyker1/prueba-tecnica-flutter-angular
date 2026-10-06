import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { CartOrder, CartsApiResponse } from '../models/order.model';

@Injectable({
  providedIn: 'root'
})
export class OrdersService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = 'https://dummyjson.com/carts';

  getOrders(): Observable<CartsApiResponse> {
    return this.http.get<CartsApiResponse>(this.apiUrl);
  }

  getOrderById(id: number | string): Observable<CartOrder> {
    return this.http.get<CartOrder>(`${this.apiUrl}/${id}`);
  }
}
