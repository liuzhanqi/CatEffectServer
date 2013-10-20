package models;

import javax.persistence.*;
import java.util.Date;

@Entity
public class Transaction {
    @Id
    private Integer transactionId;
    @ManyToOne
    @JoinColumn(name="account_id")
    private Account account;
    private Integer type; // 0 for top-up, 1 for payments.
    private Integer amount; // This is a positive integer.
    private Date time;
    @OneToOne(mappedBy = "transaction")
    private Order order;
    @ManyToOne
    @JoinColumn(name = "manager_id")
    private Manager manager;

    public Integer getTransactionId() {return transactionId;}
    public Account getAccount() {return account;}
    public Integer getType() {return type;}
    public Integer getAmount() {return amount;}
    public Date getTime() {return time;}
    public Order getOrder() {return order;}
    public Manager getManager() {return manager;}

    public void setAccount(Account newAccount) {account = newAccount;}
    public void setType(Integer newType) {type = newType;}
    public void setAmount(Integer newAmount) {amount = newAmount;}
    public void setTime(Date newTime) {time = newTime;}
    public void setOrder(Order newOrder) {order = newOrder;}
    public void setManager(Manager newManager) {manager = newManager;}
}
